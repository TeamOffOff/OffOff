package com.yuuuzzzin.offoff_android.viewmodel

import android.util.Log
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.yuuuzzzin.offoff_android.OffoffApplication
import com.yuuuzzzin.offoff_android.service.models.*
import com.yuuuzzzin.offoff_android.service.repository.BoardRepository
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

    val content = MutableLiveData("")

    private val _loading = MutableLiveData<Event<Boolean>>()
    val loading: LiveData<Event<Boolean>> = _loading

    private val _post = MutableLiveData<Post>()
    val post: LiveData<Post> get() = _post

    private val _newPost = MutableLiveData<Post>()
    val newPost: LiveData<Post> get() = _newPost

    private val _commentList = MutableLiveData<List<Comment>>()
    val commentList: LiveData<List<Comment>> get() = _commentList

    private val _newCommentList = MutableLiveData<List<Comment>>()
    val newCommentList: LiveData<List<Comment>> get() = _newCommentList

    private val _replyList = MutableLiveData<List<Comment>>()
    val replyList: LiveData<List<Comment>> get() = _replyList

    private val _comment = MutableLiveData<Comment>()
    val comment: LiveData<Comment> get() = _comment

    private val _reply = MutableLiveData<Reply>()
    val reply: LiveData<Reply> get() = _reply

    private val _imageList = MutableLiveData<List<Image>>()
    val imageList: LiveData<List<Image>> get() = _imageList

    // 게시글 좋아요 완료 여부
    private val _isLikedPost = MutableLiveData<Event<Boolean>>()
    val isLikedPost: LiveData<Event<Boolean>> = _isLikedPost

    // 게시글 스크랩 완료 여부
    private val _isBookmarkedPost = MutableLiveData<Event<Boolean>>()
    val isBookmarkedPost: LiveData<Event<Boolean>> = _isBookmarkedPost

    // 게시글 신고 완료 여부
    private val _isReportedPost = MutableLiveData<Event<Boolean>>()
    val isReportedPost: LiveData<Event<Boolean>> = _isReportedPost

    // 대댓글 작성 이벤트
    private val _commentSuccessEvent = MutableLiveData<Event<Boolean>>()
    val commentSuccessEvent: LiveData<Event<Boolean>> = _commentSuccessEvent

    // 대댓글 작성 이벤트
    private val _replySuccessEvent = MutableLiveData<Event<Boolean>>()
    val replySuccessEvent: LiveData<Event<Boolean>> = _replySuccessEvent

    // 댓글 좋아요 완료 여부
    private val _isLikedComment = MutableLiveData<Event<Boolean>>()
    val isLikedComment: LiveData<Event<Boolean>> = _isLikedComment

    private val _showReplyOptionDialog = MutableLiveData<Event<Reply>>()
    val showReplyOptionDialog: LiveData<Event<Reply>> = _showReplyOptionDialog

    private val _showMyReplyOptionDialog = MutableLiveData<Event<Reply>>()
    val showMyReplyOptionDialog: LiveData<Event<Reply>> = _showMyReplyOptionDialog

    fun getPost(postId: String, boardType: String, isRefreshing: Boolean) {

        if (!isRefreshing)
            _loading.postValue(Event(true))

        viewModelScope.launch(Dispatchers.IO) {
            repository.getPost(OffoffApplication.pref.token.toString(), postId, boardType)
                .let { response ->
                    if (response.isSuccessful) {
                        _post.postValue(response.body())
                        Log.d("tag_success", response.body().toString())
                    } else {
                        Log.d("tag_fail", "getPost Error: ${response.code()}")
                    }
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

    fun likePost(postId: String, boardType: String) {

        _loading.postValue(Event(true))

        val activityItem = ActivityItem(
            id = postId,
            boardType = boardType,
            activity = "likes"
        )

        viewModelScope.launch(Dispatchers.IO) {
            repository.doPostActivity(OffoffApplication.pref.token.toString(), activityItem)
                .let { response ->
                    if (response.isSuccessful && response.code() == CREATED) {
                        _loading.postValue(Event(false))
                        _isLikedPost.postValue(Event(true))
                        Log.d("tag_success", "likePost: ${response.body()}")
                    } else if (response.code() == NOT_MODIFIED) {
                        _loading.postValue(Event(false))
                        _isLikedPost.postValue(Event(false))
                        Log.d("tag_fail", "likePost Error: ${response.code()}")
                    } else {
                        Log.d("tag_fail", "likePost Error: ${response.code()}")
                    }
                }

        }
    }

    fun bookmarkPost(postId: String, boardType: String) {

        _loading.postValue(Event(true))

        val activityItem = ActivityItem(
            id = postId,
            boardType = boardType,
            activity = "bookmarks"
        )

        viewModelScope.launch(Dispatchers.IO) {
            repository.doPostActivity(OffoffApplication.pref.token.toString(), activityItem)
                .let { response ->
                    if (response.isSuccessful) {
                        _loading.postValue(Event(false))

                        when (response.code()) {
                            CREATED -> {
                                _isBookmarkedPost.postValue(Event(true))
                                Log.d("tag_success", "bookmarkPost: ${response.body()}")
                            }
                            OK ->
                                _isBookmarkedPost.postValue(Event(false))
                        }
                    } else {
                        Log.d("tag_fail", "bookmarkPost Error: ${response.code()}")
                    }
                }

        }
    }

    fun reportPost(postId: String, boardType: String) {

        _loading.postValue(Event(true))

        val activityItem = ActivityItem(
            id = postId,
            boardType = boardType,
            activity = "reports"
        )

        viewModelScope.launch(Dispatchers.IO) {
            repository.doPostActivity(OffoffApplication.pref.token.toString(), activityItem)
                .let { response ->
                    if (response.isSuccessful) {
                        _loading.postValue(Event(false))

                        when (response.code()) {
                            CREATED -> {
                                _isReportedPost.postValue(Event(true))
                                Log.d("tag_success", "reportPost: ${response.body()}")
                            }
                            OK ->
                                _isReportedPost.postValue(Event(false))
                        }
                    } else {
                        Log.d("tag_fail", "reportPost Error: ${response.code()}")
                    }
                }

        }
    }

    fun getComments(postId: String, boardType: String, isRefreshing: Boolean) {
        viewModelScope.launch(Dispatchers.IO) {
            repository.getComments(OffoffApplication.pref.token.toString(), postId, boardType)
                .let { response ->
                    if (response.isSuccessful) {
                        if (!isRefreshing)
                            _loading.postValue(Event(false))

                        Log.d("tag_success", "getComments: ${response.body()}")

                        if (!response.body()!!.commentList.isNullOrEmpty()) {
                            _commentList.postValue(response.body()!!.commentList)
                        }
                    } else {
                        Log.d("tag_fail", "getComments Error: ${response.code()}")
                    }
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

        Log.d("tag_comment", comment.toString())

        viewModelScope.launch(Dispatchers.IO) {
            repository.writeComment(OffoffApplication.pref.token!!, comment).let { response ->
                if (response.isSuccessful) {
                    _newCommentList.postValue(response.body()!!.commentList)
                    Log.d("tag_success", "writeComment: ${response.body()}")
                } else {
                    Log.d("tag_fail", "writeComment Error: $response")
                }
            }
        }
    }

    fun likeComment(commentId: String, boardType: String) {

        _loading.postValue(Event(true))

        val activityItem = ActivityItem(
            id = commentId,
            boardType = boardType,
            activity = "likes"
        )

        viewModelScope.launch(Dispatchers.Main) {
            repository.likeComment(OffoffApplication.pref.token.toString(), activityItem)
                .let { response ->
                    if (response.isSuccessful) {
                        _loading.postValue(Event(false))
                        Log.d("tag_success", "likeComment: ${response.body()}")

                        if (!response.body()!!.id.isNullOrEmpty()) {
                            _comment.postValue(response.body())
                            _isLikedComment.postValue(Event(true))
                        } else {
                            _isLikedComment.postValue(Event(false))
                        }
                    } else {
                        Log.d("tag_fail", "likeComment Error: ${response.code()}")
                    }
                }

        }
    }

    fun deleteComment(commentId: String, postId: String, boardType: String) {

        _loading.postValue(Event(true))

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
                        _loading.postValue(Event(false))
                        _commentList.postValue(response.body()!!.commentList)
                        Log.d("tag_success", "deleteComment: ${response.body()}")
                    } else {
                        Log.d("tag_fail", "deleteComment Error: ${response.code()}")
                    }
                }

        }
    }

    fun writeReply(postId: String, boardType: String, parentReplyId: String) {

        val reply = Reply(
            id = "${parentReplyId}_${dateFormat.format(System.currentTimeMillis())}",
            boardType = boardType,
            postId = postId,
            parentReplyId = parentReplyId,
            content = content.value!!
        )

        Log.d("tag_comment", comment.toString())

        viewModelScope.launch(Dispatchers.IO) {
            repository.writeReply(OffoffApplication.pref.token!!, reply).let { response ->
                if (response.isSuccessful) {
                    _replyList.postValue(response.body()!!.commentList)
                    _replySuccessEvent.postValue(Event(true))
                    Log.d("tag_success", "writeReply: ${response.body()}")
                } else {
                    Log.d("tag_fail", "writeReply Error: $response")
                }
            }
        }
    }

    fun likeReply(replyId: String, boardType: String) {

        _loading.postValue(Event(true))

        val activityItem = ActivityItem(
            id = replyId,
            boardType = boardType,
            activity = "likes"
        )

        viewModelScope.launch(Dispatchers.Main) {
            repository.likeReply(OffoffApplication.pref.token.toString(), activityItem)
                .let { response ->
                    if (response.isSuccessful) {
                        _loading.postValue(Event(false))
                        Log.d("tag_success", "likeReply: ${response.body()}")
                        if (!response.body()!!.id.isNullOrEmpty()) {
                            _reply.postValue(response.body())
                            _isLikedComment.postValue(Event(true))
                        } else {
                            _isLikedComment.postValue(Event(false))
                        }
                    } else {
                        Log.d("tag_fail", "likeReply Error: ${response.code()}")
                    }
                }

        }
    }

    fun deleteReply(replyId: String, postId: String, boardType: String, parentReplyId: String) {

        _loading.postValue(Event(true))

        val replySend = ReplySend(
            id = replyId,
            boardType = boardType,
            postId = postId,
            parentReplyId = parentReplyId,
            author = OffoffApplication.user.id
        )

        viewModelScope.launch(Dispatchers.IO) {

            repository.deleteReply(OffoffApplication.pref.token.toString(), replySend)
                .let { response ->
                    if (response.isSuccessful) {
                        _loading.postValue(Event(false))
                        _commentList.postValue(response.body()!!.commentList)
                        Log.d("tag_success", "deleteReply: ${response.body()}")
                    } else {
                        Log.d("tag_fail", "deleteReply Error: ${response.code()}")
                    }
                }

        }
    }

    fun getPostImages(postId: String, boardType: String) {

        viewModelScope.launch(Dispatchers.IO) {
            repository.getPostImages(OffoffApplication.pref.token.toString(), postId, boardType)
                .let { response ->
                    if (response.isSuccessful) {
                        //_imageList.postValue(response.body()!!.image)
                        //OffoffApplication.imageList = response.body()!!.image
                        Log.d("tag_success", "getPostImages: ${response.body()}")
                    } else {
                        Log.d("tag_fail", "getPostImages Error: ${response.code()}")
                    }
                }

        }
    }

    fun showReplyOptionDialog(reply: Reply) {
        _showReplyOptionDialog.postValue(Event(reply))
    }

    fun showMyReplyOptionDialog(reply: Reply) {
        _showMyReplyOptionDialog.postValue(Event(reply))
    }

    fun update(commentList: Array<Comment>) {
        _commentList.postValue(commentList.toList())
        //_commentList.value!!.get(index = position).likes = comment.likes
    }

    companion object {
        const val OK = 200
        const val CREATED = 201
        const val NOT_MODIFIED = 304
    }
}