using System;
using System.Text;

namespace KdTree
{
	public class KdTreeNode<TKey, TValue>
	{
		public this()
		{
		}

		public this(TKey[] point, TValue value)
		{
			Point = point;
			Value = value;
		}

		public TKey[] Point ~ delete _;
		public TValue Value = default(TValue);

		public KdTreeNode<TKey, TValue> LeftChild = null;
		public KdTreeNode<TKey, TValue> RightChild = null;

		public KdTreeNode<TKey, TValue> this[int compare]
		{
			get
			{
				if (compare <= 0)
					return LeftChild;
				else
					return RightChild;
			}
			set
			{
				if (compare <= 0)
					LeftChild = value;
				else
					RightChild = value;
			}
		}

		public bool IsLeaf
		{
			get
			{
				return (LeftChild == null) && (RightChild == null);
			}
		}

		public String ToString()
		{
			var sb = new String();
			String buffer="";
			for (var dimension = 0; dimension < Point.Count; dimension++)
			{
				Point[dimension].ToString(buffer);
				sb..Append( + "\t");
				delete(buffer);
			}

			if (Value == null)
				sb..Append("null");
			else{

				Value.ToString(buffer);
				sb..Append(buffer);
				delete(buffer);
			}
			delete(buffer);
			return sb;
		}
	}
}