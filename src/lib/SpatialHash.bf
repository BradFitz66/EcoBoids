using System;
using System.Collections;
using Boids.lib;
using System.Linq;
using raylib_beef.Types;
using static raylib_beef.Raylib;
namespace Boids.lib
{
	public class SpatialHash<T> : Dictionary<Vector2, List<T>> where T : Entity
	{
		private int cellSize;

		public this(int cellSize)
		{
			this.cellSize = cellSize;
		}

		public ~this()
		{
			this.ClearLists();
			this.Clear();
			//DeleteDictionaryAndValues!(this);
		}

		
		//Queries a different cell from the given position. (eg: cellsLeft=1 will make it check a cell to the left)
		public void QueryRelativePosition(Vector2 vector, int cellsLeft, int cellsUp, int cellsRight, int cellsDown, ref List<T> output)
		{
			Vector2 gridVec = VectorToGridSpace(vector);
			float posLeft = ((float)cellsLeft) * cellSize;
			float posUp = ((float)cellsUp) * cellSize;
			float posRight = ((float)cellsRight) * cellSize;
			float posDown = ((float)cellsDown) * cellSize;
			QueryPosition(vector + (posLeft * Vector2.Left) +
				(posUp * Vector2.Up) +
				(posRight * Vector2.Right) +
				(posDown * cellsDown), ref output);
		}

		public void UpdatePosition(Vector2 newVector, Vector2 prevVector, T obj)
		{
			Vector2 newGridPos = VectorToGridSpace(newVector);
			Vector2 oldGridPos = VectorToGridSpace(prevVector);
			//If still in same cell, don't do anything
			if (newGridPos == oldGridPos)
				return;

			Remove(obj);
			Add(obj);
		}

		public void QueryPosition(Vector2 vector, ref List<T> output)
		{
			Vector2 gridPos = VectorToGridSpace(vector);
			if (ContainsKey(gridPos))
			{
				output.Clear();
				output.AddRange(this[gridPos]);
			}
			else
				return;
		}

		public Vector2 VectorToGridSpace(Vector2 v)
		{
			Vector2 nV = Vector2(
				(int)Math.Round(v.x / cellSize) * cellSize,
				(int)Math.Round(v.y / cellSize) * cellSize
				);
			return nV;
		}

		//Clears all values. First, we delete all the items and then we delete this list itself.
		public void ClearLists()
		{
			for (var i in this) do
				{
					ClearAndDeleteItems(i.value);
					delete (i.value);
				}
		}

		//Mainly for debugging. Can be completely removed.
		public void Draw()
		{
			for (var pos in this)
			{
				DrawRectangleLines((int32)pos.key.x - int32(cellSize / 2), (int32)pos.key.y - int32(cellSize / 2), (int32)cellSize, (int32)cellSize, Color.RED);
			}
		}

		public void Add(T item)
		{
			Vector2 gridPos = VectorToGridSpace(item.position);
			if (!ContainsKey(gridPos))
			{
				this.Add(gridPos, new List<T>());
			}
			this[gridPos].Add(item);
		}

		//Two functions for Contains. Probably redundant, but this means I can check if we contain an objects position
		// given the actual object or just it's position
		public bool Contains(T item)
		{
			Vector2 gridPos = VectorToGridSpace(item.position);
			return ContainsKey(gridPos);
		}
		public bool Contains(Vector2 pos, bool InGridPosition = false)
		{
			Vector2 gridPos = !InGridPosition ? VectorToGridSpace(pos) : pos;
			return ContainsKey(gridPos);
		}


		public void CopyTo(Span<T> span)
		{
			ThrowUnimplemented();
		}

		public bool Remove(T item)
		{
			Vector2 oldGridCell = VectorToGridSpace(((Boid)item).prevPosition);
			if (Contains(oldGridCell, true) && this[oldGridCell].Count > 0)
			{
				int index = this[oldGridCell].FindIndex(scope (x) => { return x == item; });

				if (index > this[oldGridCell].Count || index < 0)
				{
					Console.WriteLine("What the fuck?");
					return false;
				}
				this[oldGridCell].RemoveAt(index);
				if (this[oldGridCell].Count == 0)
				{
					//Free memory
					delete (this[oldGridCell]);
					//Remove key
					Remove(oldGridCell);
				}
				return true;
			}
			return false;
		}
	}
}