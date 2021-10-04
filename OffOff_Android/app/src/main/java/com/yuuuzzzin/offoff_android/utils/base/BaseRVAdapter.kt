package com.yuuuzzzin.offoff_android.utils.base

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.annotation.LayoutRes
import androidx.databinding.DataBindingUtil
import androidx.databinding.ViewDataBinding
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.yuuuzzzin.offoff_android.BR
import com.yuuuzzzin.offoff_android.utils.Identifiable

abstract class BaseRVAdapter<T : Identifiable, VB : ViewDataBinding>(
    private val itemClick: (T) -> Unit,
    @LayoutRes private val layoutRes: Int
) : ListAdapter<T, BaseRVAdapter.BaseViewHolder<T>>(object : DiffUtil.ItemCallback<T>() {
    /*
    * DiffUtil의 ItemCallback을 이용해
    * 갱신 전 데이터와 갱신 후 데이터의 차이점을 계산해
    * 효율적으로 업데이트
    * */

    private val items = mutableListOf<T>()

    // 두 아이템이 동일한 아이템인가? (identifier 기준 비교)
    override fun areItemsTheSame(oldItem: T, newItem: T): Boolean {
        return oldItem.identifier == newItem.identifier
    }

    // 두 아이템이 동일한 내용을 가지는가?
    override fun areContentsTheSame(oldItem: T, newItem: T): Boolean {
        return oldItem == newItem
    }
}) {

    /* (뷰가 생성될 때) 레이아웃 생성 */
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<T> {
        val binding: VB =
            DataBindingUtil.inflate(LayoutInflater.from(parent.context), layoutRes, parent, false)

        return BaseViewHolder(binding, itemClick)
    }

    /* (뷰가 재활용될 때) 뷰홀더가 뷰에 그려졌을 때 데이터를 바인드해주는 함수 */
    override fun onBindViewHolder(holder: BaseViewHolder<T>, position: Int) {
        holder.bind(getItem(position))
    }

    open class BaseViewHolder<T>(
        private val binding: ViewDataBinding,
        private val itemClick: (T) -> Unit
    ) :
        RecyclerView.ViewHolder(binding.root) {

        open fun bind(item: T) {
            binding.setVariable(BR.item, item)
            binding.executePendingBindings()
            binding.root.setOnClickListener {
                itemClick(item)
            }
        }
    }
}
