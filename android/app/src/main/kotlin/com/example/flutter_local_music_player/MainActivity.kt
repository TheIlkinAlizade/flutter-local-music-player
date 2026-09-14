package com.example.flutter_local_music_player

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "local_music_player/android_storage"
        private const val REQUEST_PICK_FOLDER = 9001
    }

    private var pendingFolderResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "pickFolder" -> {
                    if (pendingFolderResult != null) {
                        result.error(
                            "PICKER_BUSY",
                            "A folder picker is already open",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    pendingFolderResult = result

                    try {
                        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
                            addFlags(Intent.FLAG_GRANT_PREFIX_URI_PERMISSION)
                        }

                        startActivityForResult(
                            intent,
                            REQUEST_PICK_FOLDER
                        )
                    } catch (e: Exception) {
                        pendingFolderResult = null

                        result.error(
                            "PICKER_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                "persistTreePermission" -> {
                    val uriString = call.argument<String>("uri")

                    if (uriString.isNullOrBlank()) {
                        result.error(
                            "INVALID_URI",
                            "Missing tree URI",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val uri = Uri.parse(uriString)

                        contentResolver.takePersistableUriPermission(
                            uri,
                            Intent.FLAG_GRANT_READ_URI_PERMISSION
                        )

                        result.success(true)
                    } catch (e: Exception) {
                        result.error(
                            "PERMISSION_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                "scanTree" -> {
                    val uriString = call.argument<String>("uri")

                    if (uriString.isNullOrBlank()) {
                        result.error(
                            "INVALID_URI",
                            "Missing tree URI",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val uri = Uri.parse(uriString)

                        if (uri.scheme != "content") {
                            throw IllegalArgumentException(
                                "Invalid URI: $uriString"
                            )
                        }

                        result.success(scanTree(uri))
                    } catch (e: Exception) {
                        result.error(
                            "SCAN_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                "getFileInfo" -> {
                    val uriString = call.argument<String>("uri")

                    if (uriString.isNullOrBlank()) {
                        result.error(
                            "INVALID_URI",
                            "Missing file URI",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val uri = Uri.parse(uriString)

                        if (uri.scheme != "content") {
                            throw IllegalArgumentException(
                                "Invalid URI: $uriString"
                            )
                        }

                        result.success(getFileInfo(uri))
                    } catch (e: Exception) {
                        result.error(
                            "FILE_INFO_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                "copyToCache" -> {
                    val uriString = call.argument<String>("uri")

                    if (uriString.isNullOrBlank()) {
                        result.error(
                            "INVALID_URI",
                            "Missing file URI",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val uri = Uri.parse(uriString)

                        if (uri.scheme != "content") {
                            throw IllegalArgumentException(
                                "Invalid URI: $uriString"
                            )
                        }

                        result.success(copyToCache(uri))
                    } catch (e: Exception) {
                        result.error(
                            "COPY_ERROR",
                            e.message,
                            null
                        )
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(
            requestCode,
            resultCode,
            data
        )

        if (requestCode != REQUEST_PICK_FOLDER) {
            return
        }

        val result = pendingFolderResult
        pendingFolderResult = null

        if (result == null) {
            return
        }

        if (resultCode != RESULT_OK || data?.data == null) {
            result.success(null)
            return
        }

        val uri = data.data!!

        try {
            contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
            )
        } catch (e: Exception) {
            result.error(
                "PERMISSION_ERROR",
                e.message,
                null
            )
            return
        }

        result.success(uri.toString())
    }

    private fun scanTree(treeUri: Uri): List<String> {
        val result = mutableListOf<String>()

        val treeDocumentId =
            DocumentsContract.getTreeDocumentId(treeUri)

        scanDirectory(
            treeUri,
            treeDocumentId,
            result
        )

        return result
    }

    private fun scanDirectory(
        treeUri: Uri,
        parentDocumentId: String,
        result: MutableList<String>
    ) {
        val childrenUri =
            DocumentsContract.buildChildDocumentsUriUsingTree(
                treeUri,
                parentDocumentId
            )

        val projection = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE
        )

        contentResolver.query(
            childrenUri,
            projection,
            null,
            null,
            null
        )?.use { cursor ->

            val documentIdIndex =
                cursor.getColumnIndex(
                    DocumentsContract.Document.COLUMN_DOCUMENT_ID
                )

            val nameIndex =
                cursor.getColumnIndex(
                    DocumentsContract.Document.COLUMN_DISPLAY_NAME
                )

            val mimeIndex =
                cursor.getColumnIndex(
                    DocumentsContract.Document.COLUMN_MIME_TYPE
                )

            if (documentIdIndex < 0 ||
                nameIndex < 0 ||
                mimeIndex < 0
            ) {
                throw IllegalStateException(
                    "Android document provider returned invalid columns"
                )
            }

            while (cursor.moveToNext()) {
                val documentId =
                    cursor.getString(documentIdIndex)

                val name =
                    cursor.getString(nameIndex)

                val mimeType =
                    cursor.getString(mimeIndex)

                if (mimeType ==
                    DocumentsContract.Document.MIME_TYPE_DIR
                ) {
                    scanDirectory(
                        treeUri,
                        documentId,
                        result
                    )
                } else if (
                    isAudioFile(
                        name,
                        mimeType
                    )
                ) {
                    val documentUri =
                        DocumentsContract.buildDocumentUriUsingTree(
                            treeUri,
                            documentId
                        )

                    result.add(
                        documentUri.toString()
                    )
                }
            }
        }
    }

    private fun isAudioFile(
        name: String,
        mimeType: String
    ): Boolean {
        val lowerName = name.lowercase()

        return lowerName.endsWith(".mp3") ||
                lowerName.endsWith(".flac") ||
                lowerName.endsWith(".m4a") ||
                lowerName.endsWith(".wav") ||
                mimeType.startsWith("audio/")
    }

    private fun getFileInfo(uri: Uri): Map<String, Any?> {
        val projection = arrayOf(
            DocumentsContract.Document.COLUMN_SIZE,
            DocumentsContract.Document.COLUMN_LAST_MODIFIED
        )

        contentResolver.query(
            uri,
            projection,
            null,
            null,
            null
        )?.use { cursor ->

            if (cursor.moveToFirst()) {

                val sizeIndex =
                    cursor.getColumnIndex(
                        DocumentsContract.Document.COLUMN_SIZE
                    )

                val modifiedIndex =
                    cursor.getColumnIndex(
                        DocumentsContract.Document.COLUMN_LAST_MODIFIED
                    )

                val size =
                    if (sizeIndex >= 0 &&
                        !cursor.isNull(sizeIndex)
                    ) {
                        cursor.getLong(sizeIndex)
                    } else {
                        0L
                    }

                val modified =
                    if (modifiedIndex >= 0 &&
                        !cursor.isNull(modifiedIndex)
                    ) {
                        cursor.getLong(modifiedIndex)
                    } else {
                        0L
                    }

                return mapOf(
                    "size" to size,
                    "modified" to modified
                )
            }
        }

        throw IllegalStateException(
            "Unable to read file information"
        )
    }

    private fun copyToCache(uri: Uri): String {
        val fileName =
            queryDisplayName(uri)
                ?: "audio_${System.currentTimeMillis()}"

        val safeName =
            fileName.replace(
                Regex("[^A-Za-z0-9._-]"),
                "_"
            )

        val cacheDirectory =
            File(
                cacheDir,
                "music_metadata"
            )

        if (!cacheDirectory.exists()) {
            cacheDirectory.mkdirs()
        }

        val outputFile =
            File(
                cacheDirectory,
                "${System.currentTimeMillis()}_$safeName"
            )

        contentResolver.openInputStream(uri)?.use { input ->
            outputFile.outputStream().use { output ->
                input.copyTo(output)
            }
        } ?: throw IllegalStateException(
            "Unable to open audio document"
        )

        return outputFile.absolutePath
    }

    private fun queryDisplayName(uri: Uri): String? {
        val projection = arrayOf(
            DocumentsContract.Document.COLUMN_DISPLAY_NAME
        )

        contentResolver.query(
            uri,
            projection,
            null,
            null,
            null
        )?.use { cursor ->

            if (cursor.moveToFirst()) {
                return cursor.getString(0)
            }
        }

        return null
    }
}