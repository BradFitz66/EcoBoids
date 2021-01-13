using System;

struct ItemPriority<TItem, TPriority>
{
	public TItem Item;
	public TPriority Priority;
}

namespace KdTree
{
    public class PriorityQueue<TItem, TPriority> : IPriorityQueue<TItem, TPriority>
	{
		public this(int capacity, ITypeMath<TPriority> priorityMath)
		{
			

			this.capacity = capacity;
			queue = new ItemPriority<TItem, TPriority>[capacity];

			this.priorityMath = priorityMath;
		}
		
		///<remarks>
		///This constructor will use a default capacity of 4.
		///</remarks>
		public this(ITypeMath<TPriority> priorityMath)
		{
			this.capacity = 4;
			queue = new ItemPriority<TItem, TPriority>[capacity];

			this.priorityMath = priorityMath;
		}

		private ITypeMath<TPriority> priorityMath;

		private ItemPriority<TItem, TPriority>[] queue ~ delete _;

		private int capacity;

		private int count;
		public int Count { get { return count; } }

		// Try to avoid unnecessary slow memory reallocations by creating your queue with an ample capacity
		private void ExpandCapacity()
		{
			// Double our capacity
			capacity *= 2;

			// Create a new queue
			var newQueue = new ItemPriority<TItem, TPriority>[capacity];

			// Copy the contents of the original queue to the new one
			Array.Copy(queue, newQueue, queue.Count);

			// Copy the new queue over the original one
			queue = newQueue;
		}

		public void Enqueue(TItem item, TPriority priority)
		{
			if (++count > capacity)
				ExpandCapacity();

			int newItemIndex = count - 1;

			ItemPriority<TItem,TPriority> newItem=ItemPriority<TItem, TPriority>();

			newItem.Item=item;
			newItem.Priority=priority;

			queue[newItemIndex] = newItem;

			ReorderItem(newItemIndex, -1); 
		}

		public TItem Dequeue()
		{
			TItem item = queue[0].Item;

			queue[0].Item = default(TItem);
			queue[0].Priority = priorityMath.MinValue;

			ReorderItem(0, 1);

			count--;

			return item;
		}

		private void ReorderItem(int index, int direction)
		{
			
			int i=index;
			var item = queue[i];

			int nextIndex = i+ direction;

			while ((nextIndex >= 0) && (nextIndex < count))
			{
				var next = queue[nextIndex];

				int compare = priorityMath.Compare(item.Priority, next.Priority);

				// If we're moving up and our priority is higher than the next priority then swap
				// Or if we're moving down and our priority is lower than the next priority then swap
				if (
					((direction == -1) && (compare > 0))
					||
					((direction == 1) && (compare < 0))
					)
				{
					queue[index] = next;
					queue[nextIndex] = item;

					i += direction;
					nextIndex += direction;
				}
				else
					break;
			}
		}

		public TItem GetHighest()
		{
			return queue[0].Item;
		}

		public TPriority GetHighestPriority()
		{
			return queue[0].Priority;
		}
	}
}
