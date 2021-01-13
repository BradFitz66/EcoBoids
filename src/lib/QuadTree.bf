using System.Collections;
using System;
using raylib_beef.Types;
using static raylib_beef.Raymath;
using static raylib_beef.Raylib;
namespace Boids.lib
{
	class QuadTree<T> where T = Entity
	{
		List<T> items ~ delete _;
		Rectangle rect;
		int mDepth = 0;
		int curDepth = 0;
		int mItemsPerNode = 1;
		List<QuadTree<T>> bins ~ DeleteContainerAndItems!(_);
		public this(int maxDepth, int maxItemsPerNode, Rectangle extent, int initDepth)
		{
			bins = new List<QuadTree<T>>();
			items = new List<T>();
			mDepth = maxDepth;
			mItemsPerNode = maxItemsPerNode;
			rect = extent;
			curDepth = initDepth;
		}

		public void Add(T item)
		{
			if (bins.Count==0)
			{
				if(items!=null)
					items.Add(item);
				else
					items=new List<T>();
				if (curDepth < mDepth && items.Count > mItemsPerNode)
				{
					Subdivide();
				}
			}
			else{
				int binIndex = getBinIndex(item.position,0);
				if (binIndex > -1 && binIndex<bins.Count){
				 	bins[binIndex].Add(item);
				}
			}
		}

		public void Clear()
		{
			if(items!=null){
				items.Clear();
			}
			if (bins.Count != 0)
			{
				for (int i = 0; i < bins.Count; i++)
				{
					bins[i].Clear();
				}
				ClearAndDeleteItems(bins);
			}
		}

		public void Subdivide()
		{
			if (bins.Count != 0) return;
			let w = rect.width * 0.5f;
			let h = rect.height * 0.5f;

			for (int i = 0; i < 4; ++i)
			{
				QuadTree<T> bin=new QuadTree<T>(mDepth, mItemsPerNode, Rectangle(rect.x + i % 2 * w, this.rect.y + Math.Floor(i * 0.5f) * h, w, h), curDepth + 1);
				bins.Add(bin);
			}
			for (int i = 0; i < items.Count; i++)
			{
				int binIndex = getBinIndex(items[i].position);
				if (binIndex > -1 && binIndex<bins.Count)
					bins[binIndex].Add(items[i]);
			}
			DeleteAndNullify!(items);
		}

		public void getItemsInRadius(ref List<T> list, float x, float y, float radius)
		{
			float radiusSqr = radius * radius;

			if (bins.Count != 0)
			{
				for (int i = 0; i < bins.Count; i++)
				{
					bins[i].getItemsInRadius(ref list, x, y, radius);
				}
			}
			else
			{
				for (int i = 0; i < items.Count; i++)
				{
					float dist = Vector2Distance(items[i].position, .(x, y));
					if (dist <= radiusSqr)
						list.Add(items[i]);
				}
			}
		}
		private int getBinIndex(Vector2 pos, int range = 0)
		{
			if (!rect.Contains(pos)) return -1;
			let w = rect.width * 0.5f; let h = this.rect.height * 0.5f;
			let xx = int(Math.Floor((pos.x - rect.x) / w));
			let yy = int(Math.Floor((pos.y - rect.y) / h));
			return xx + yy * 2;
		}
		public void Draw()
		{
			DrawRectangleLines((int32)rect.x, (int32)rect.y, (int32)rect.width, (int32)rect.height, Color.WHITE);
			if (bins.Count != 0)
			{
				for (int i = 0; i < bins.Count; i++)
				{
					bins[i].Draw();
				}
			}
		}
	}
}
