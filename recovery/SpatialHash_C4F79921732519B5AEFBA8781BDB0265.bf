using System;
using System.Collections;
using Boids.lib;
using System.Linq;
using raylib_beef.Types;
using static raylib_beef.Raylib;
public class SpatialHash<T> where T : Entity
{
	private Dictionary<Vector2, List<T>> dict;
	private int cellSize;

	public this(int cellSize)
	{
		this.cellSize = cellSize;
		dict = new Dictionary<Vector2, List<T>>();
	}

	public ~this(){
		Clear();
		dict.Clear();
		DeleteDictionaryAndValues!(dict);
	}

	public void Insert(Vector2 vector, T obj)
	{
		Vector2 gridPos = VectorToGridSpace(vector);
		if (!dict.ContainsKey(gridPos))
		{
			dict.Add(gridPos, new List<T>());
		}
		dict[gridPos].Add(obj);
	}


	public void UpdatePosition(Vector2 newVector, Vector2 prevVector, T obj)
	{
		Vector2 newGridPos = VectorToGridSpace(newVector);
		Vector2 oldGridPos = VectorToGridSpace(prevVector);
		//If still in same cell, don't do anything
		if (newGridPos == oldGridPos)
			return;

		if(dict.ContainsKey(oldGridPos)){
		List<T> objs = dict[oldGridPos];
		int objInd = objs.FindIndex(
			scope (x) =>
			{
				return x == obj;
			});
			Remove(oldGridPos, objInd);
		}



		Insert(newVector, obj);
	}

	private void Remove(Vector2 gridCell, int index)
	{
		//Remove obj from cell and delete cell if it's now empty. (Is this even a good idea? Could this lead to the
		// memory that list was occupying being overwritten?)


		dict[gridCell].RemoveAt(index);
		if (dict[gridCell].Count == 0)
		{
			DeleteAndNullify!(dict[gridCell]);
			dict.Remove(gridCell);

		}
	}

	public void QueryPosition(Vector2 vector, ref List<T> output)
	{
		Vector2 gridPos = VectorToGridSpace(vector);
		if(dict.ContainsKey(gridPos)){
			output.Clear();
			output.AddRange(dict[gridPos]);
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


	public bool ContainsKey(Vector2 vector)
	{
		return false;
	}

	public void Clear()
	{
		for(var i in dict) do{
			ClearAndDeleteItems(i.value);
			delete(i.value);
		}
	}

	public void Draw()
	{
		for(var pos in dict){
			DrawRectangleLines((int32)pos.key.x-int32(cellSize/2),(int32)pos.key.y-int32(cellSize/2),(int32)cellSize,(int32)cellSize,Color.RED);
		}
	}
}