package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.service.models.*
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
import com.yuuuzzzin.offoff_android.utils.DateUtils.currentTime
import com.yuuuzzzin.offoff_android.utils.DateUtils.dateFormat
import com.yuuuzzzin.offoff_android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class PostViewModel
@Inject
constructor(
    private val repository: BoardRepository
) : ViewModel() {

    lateinit var boardType: String
    lateinit var postId: String
    var parentReplyId: String?= null
    val content = MutableLiveData("")

    private val _response = MutableLiveData<Post>()
    val response: LiveData<Post> get() = _response

    private val _newPost = MutableLiveData<Post>()
    val newPost: LiveData<Post> get() = _newPost

    private val _commentList = MutableLiveData<List<Comment>>()
    val commentList: LiveData<List<Comment>> get() = _commentList

    private val _comment = MutableLiveData<Comment>()
    val comment: LiveData<Comment> get() = _comment

    private val _reply = MutableLiveData<Reply>()
    val reply: LiveData<Reply> get() = _reply

    private val _author = MutableLiveData<String>()
    val author: LiveData<String> get() = _author

    private val _likes = MutableLiveData<Int>()
    val likes: LiveData<Int> get() = _likes

    // 좋아요
    private val _successLike = MutableLiveData<Event<String>>()
    val successLike: LiveData<Event<String>> = _successLike

    // 이미 좋아요
    private val _alreadyLike = MutableLiveData<Event<String>>()
    val alreadyLike: LiveData<Event<String>> = _alreadyLike

    // 댓글
    private val _commentSuccessEvent = MutableLiveData<Event<Boolean>>()
    val commentSuccessEvent: LiveData<Event<Boolean>> = _commentSuccessEvent

    private val _showCommentDialog = MutableLiveData<Event<String>>()
    val showCommentDialog: LiveData<Event<String>> = _showCommentDialog

    private val _showMyCommentDialog = MutableLiveData<Event<String>>()
    val showMyCommentDialog: LiveData<Event<String>> = _showMyCommentDialog

    fun getPost(postId: String, boardType: String) = viewModelScope.launch(Dispatchers.IO) {

        repository.getPost(OffoffApplication.pref.token.toString(), postId, boardType)
            .let { response ->
                if (response.isSuccessful) {
                    _response.postValue(response.body())
                    _author.postValue(response.body()!!.author.id)
                    _likes.postValue(response.body()!!.likes.size)
                    Log.d("tag_success", response.body().toString())
                } else {
                    Log.d("tag_fail", "getPost Error: ${response.code()}")
                }
            }

    }

    fun deletePost(postId: String, boardType: String) {

        val postSend = PostSend(
            id = postId,
            boardType = boardType,
            author = OffoffApplication.user.id,
        )

        viewModelScope.launch(Dispatchers.IO) {

            repository.deletePost(OffoffApplication.pref.token.toString(), postSend)
                .let { response ->
                    if (response.isSuccessful) {
                        Log.d("tag_success", response.body().toString())
                    } else {
                        Log.d("tag_fail", "deletePost Error: ${response.code()}")
                    }
                }

        }
    }

    fun likePost() {

        val activityItem = ActivityItem(
            id = postId,
            boardType = boardType,
            activity = "likes"
        )

        viewModelScope.launch(Dispatchers.IO) {
            repository.doPostActivity(OffoffApplication.pref.token.toString(), activityItem)
                .let { response ->
                    if (response.isSuccessful) {
                        when (response.code()) {
                            OK -> {
                                //_response.postValue(response.body())
                                _newPost.postValue(response.body())
                                _successLike.postValue(Event("좋아요를 눌렀습니다."))
                                Log.d("tag_success", "likePost: ${response.body()}")
                            }
                            CREATED ->
                                _alreadyLike.postValue(Event("이미 좋아요한 게시글입니다."))
                        }
                    } else {
                        Log.d("tag_fail", "likePost Error: ${response.code()}")
                    }
                }

        }
    }

    fun bookmarkPost() {

        val activityItem = ActivityItem(
            id = postId,
            boardType = boardType,
            activity = "bookmarks"
        )

        viewModelScope.launch(Dispatchers.IO) {
            repository.doPostActivity(OffoffApplication.pref.token.toString(), activityItem)
                .let { response ->
                    if (response.isSuccessful) {
                        when (response.code()) {
                            OK -> {
                                _response.postValue(response.body())
                                _successLike.postValue(Event("게시물을 북마크했습니다."))
                                Log.d("tag_success", "likePost: ${response.body()}")
                            }
                            CREATED ->
                                _alreadyLike.postValue(Event("북마크를 취소헀습니다."))
                        }
                    } else {
                        Log.d("tag_fail", "likePost Error: ${response.code()}")
                    }
                }

        }
    }

    fun reportPost() {

        val activityItem = ActivityItem(
            id = postId,
            boardType = boardType,
            activity = "reports"
        )

        viewModelScope.launch(Dispatchers.IO) {
            repository.doPostActivity(OffoffApplication.pref.token.toString(), activityItem)
                .let { response ->
                    if (response.isSuccessful) {
                        when (response.code()) {
                            OK -> {
                                _newPost.postValue(response.body())
                                _successLike.postValue(Event("게시물을 신고했습니다."))
                                Log.d("tag_success", "likePost: ${response.body()}")
                            }
                            CREATED ->
                                _alreadyLike.postValue(Event("신고를 취소헀습니다."))
                        }
                    } else {
                        Log.d("tag_fail", "likePost Error: ${response.code()}")
                    }
                }

        }
    }

    fun getComments(postId: String, boardType: String) = viewModelScope.launch(Dispatchers.IO) {

        repository.getComments(OffoffApplication.pref.token.toString(), postId, boardType)
            .let { response ->
                if (response.isSuccessful) {
                    Log.d("tag_success", "getComments: ${response.body()}")
                    if (!response.body()!!.commentList.isNullOrEmpty()) {
                        _commentList.postValue(response.body()!!.commentList)
                        // count = response.body()!!.commentList.size
                    }
                } else {
                    Log.d("tag_fail", "getComments Error: ${response.code()}")
                }
            }

    }

    fun writeComment(postId: String, boardType: String) {
        //if (!check()) return

        val comment = CommentSend(
            boardType = boardType,
            postId = postId,
            content = content.value!!,
        )

        Log.d("tag_comment" ,comment.toString())

        viewModelScope.launch(Dispatchers.IO) {
            repository.writeComment(OffoffApplication.pref.token!!, comment).let { response ->
                if (response.isSuccessful) {
                    _commentList.postValue(response.body()!!.commentList)
                    _commentSuccessEvent.postValue(Event(true))
                    Log.d("tag_success", "writeComment: ${response.body()}")
                } else {
                    Log.d("tag_fail", "writeComment Error: $response")
                }
            }
        }
    }

    fun likeComment(commentId: String) {

        val activityItem = ActivityItem(
            id = commentId,
            boardType = boardType,
            activity = "likes"
        )

        viewModelScope.launch(Dispatchers.Main) {
            repository.likeComment(OffoffApplication.pref.token.toString(), activityItem)
                .let { response ->
                    if (response.isSuccessful) {
                        Log.d("tag_success", "likeComment: ${response.body()}")
                        if (!response.body()!!.id.isNullOrEmpty()) {
                            _comment.postValue(response.body())
                            _successLike.postValue(Event("좋아요를 눌렀습니다."))
                        } else {
                            _alreadyLike.postValue(Event("이미 좋아요한 댓글입니다."))
                        }
                    } else {
                        Log.d("tag_fail", "likeComment Error: ${response.code()}")
                    }
                }

        }
    }

    fun deleteComment(commentId: String, postId: String, boardType: String) {

        val commentSend = CommentSend(
            id = commentId,
            postId = postId,
            boardType = boardType,
            author = OffoffApplication.user.id,
        )

        viewModelScope.launch(Dispatchers.IO) {

            repository.deleteComment(OffoffApplication.pref.token.toString(), commentSend)
                .let { response ->
                    if (response.isSuccessful) {
                        _commentList.postValue(response.body()!!.commentList)
                        Log.d("tag_success", response.body().toString())
                    } else {
                        Log.d("tag_fail", "deleteComment Error: ${response.code()}")
                    }
                }

        }
    }

    fun writeReply(postId: String, boardType: String) {

        val reply = Reply(
            id = "${parentReplyId}_${dateFormat.format(currentTime)}",
            boardType = boardType,
            postId = postId,
            parentReplyId = parentReplyId,
            content = content.value!!
        )

        Log.d("tag_comment" ,comment.toString())

        viewModelScope.launch(Dispatchers.IO) {
            repository.writeReply(OffoffApplication.pref.token!!, reply).let { response ->
                if (response.isSuccessful) {
                    _commentList.postValue(response.body()!!.commentList)
                    _commentSuccessEvent.postValue(Event(true))
                    Log.d("tag_success", "writeReply: ${response.body()}")
                } else {
                    Log.d("tag_fail", "writeReply Error: $response")
                }
            }
        }

        parentReplyId = null
    }

    fun likeReply (id: String) {

        val activityItem = ActivityItem(
            id = id,
            boardType = boardType,
            activity = "likes"
        )

        viewModelScope.launch(Dispatchers.Main) {
            repository.likeReply(OffoffApplication.pref.token.toString(), activityItem)
                .let { response ->
                    if (response.isSuccessful) {
                        Log.d("tag_success", "likeComment: ${response.body()}")
                        if (!response.body()!!.id.isNullOrEmpty()) {
                            _reply.postValue(response.body())
                            _successLike.postValue(Event("좋아요를 눌렀습니다."))
                        } else {
                            _alreadyLike.postValue(Event("이미 좋아요한 댓글입니다."))
                        }
                    } else {
                        Log.d("tag_fail", "likeComment Error: ${response.code()}")
                    }
                }

        }
    }
    fun deleteReply(id: String, postId: String, boardType: String) {

        val replySend = ReplySend(
            id = id,
            boardType = boardType,
            postId = postId,
            parentReplyId = parentReplyId,
            author = OffoffApplication.user.id
        )

        viewModelScope.launch(Dispatchers.IO) {

            repository.deleteReply(OffoffApplication.pref.token.toString(), replySend)
                .let { response ->
                    if (response.isSuccessful) {
                        _commentList.postValue(response.body()!!.commentList)
                        Log.d("tag_success", response.body().toString())
                    } else {
                        Log.d("tag_fail", "deleteComment Error: ${response.code()}")
                    }
                }

        }
    }

    fun showMyCommentDialog(commentId: String) {
        _showMyCommentDialog.postValue(Event(commentId))
    }

    fun showCommentDialog(commentId: String) {
        _showCommentDialog.postValue(Event(commentId))
    }

    fun update(commentList: Array<Comment>) {
        _commentList.postValue(commentList.toList())
        //_commentList.value!!.get(index = position).likes = comment.likes
    }

    companion object {
        const val OK = 200
        const val CREATED = 201
    }
}