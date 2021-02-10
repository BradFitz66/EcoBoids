using System;
using System.Collections;
using Boids.lib;
using raylib_beef.Types;
class SpatialHash<T> where T = Entity
{
  /* the square cell gridLength of the grid. Must be larger than the largest shape in the space. */
	private float gridHeightRes;
	private float gridWidthRes;
	private double invCellSize;

	public this(int _width, int _height, int _cellSize)
	{
		gridWidthRes = _width;
		gridHeightRes = _height;

		cellSize = _cellSize;
		invCellSize = (double)1 / cellSize;

		gridWidth = (int)Math.Ceiling(_width * invCellSize);
		gridHeight = (int)Math.Ceiling(_height * invCellSize);

		gridLength = gridWidth * gridHeight;

		grid = new List<List<T>>(gridLength);

		for (int i = 0; i < gridLength; i++)
			grid.Add(new List<T>());
	}

	public void addBody(T b)
	{
		addIndex(b, getIndex1DVec(clampToGridVec(b.position.x, b.position.y)));
	}

	public void removeBody(T b)
	{
		removeIndexes(b);
	}

	public void updateBody(T b)
	{
		updateIndexes(b);
	}

	public void getAllBodiesSharingCellsWithBody(T body, ref List<T> bodies)
	{

		for (int i in body.gridIndex)
		{
			if (grid[i].Count == 0)
				continue;

			for (var cbd in grid[i])
			{
				if (cbd == body)
					continue;
				bodies.Add(cbd);
			}
		}
	}

	public bool isBodySharingAnyCell(T body)
	{
		for(int i=0; i<body.gridIndex.Count; i++){
			int index=body.gridIndex[i];
			if(grid[index].Count==0)
				continue;

			for(int j=0; j<grid[index].Count; j++){
				if(grid[index][j]==body)
					continue;
			}
			return true;
		}
		return false;
	}

	public int getIndex1DVec(Vector2 _pos)
	{
		return (int)(Math.Floor(_pos.x * (float)invCellSize) + gridWidth * Math.Floor(_pos.y * (float)invCellSize));
	}

	private int getIndex(float _pos)
	{
		return (int)(_pos * (float)invCellSize);
	}

	private int getIndex1D(int _x, int _y)
	{
	  // i = x + w * y;  x = i % w; y = i / w;
		return (int)(_x + gridWidth * _y);
	}

	private void updateIndexes(T b)
	{
		List<int> ind = new List<int>();
		for (int i in b.gridIndex)
		{
			removeIndex(b, i);
		}
		//b.gridIndex.splice( 0, b.gridIndex.length );
		b.gridIndex.Clear();

		aabbToGrid(.(b.aabb.x,b.aabb.y), .(b.aabb.width,b.aabb.height),ref ind);

		for (int i in ind)
		{
			addIndex(b, i);
		}
		delete(ind);
	}

	private void addIndex(T b, int _cellPos)
	{
		grid[_cellPos].Add(b);
		b.gridIndex.Add(_cellPos);
	}
	private void removeIndexes(T b)// changed from CellObject
	{
		for (int i in b.gridIndex)
		{
			removeIndex(b, i);
		}
		//b.gridIndex.splice( 0, b.gridIndex.length );
		b.gridIndex.Clear();
	}
	private void removeIndex(T b, int _pos)// changed from CellObject
	{
		grid[_pos].Remove(b);
	}

	private bool isValidGridPos(int num)
	{
		if (num < 0 || num >= gridLength)
			return false;
		else
			return true;
	}

	public Vector2 clampToGridVec(float x, float y)
	{
		Vector2 _vec = Vector2(x, y);
		_vec.x = Math.Clamp(_vec.x, 0, gridWidthRes - 1);
		_vec.x = Math.Clamp(_vec.y, 0, gridHeightRes - 1);
		return _vec;
	}

	private void aabbToGrid(Vector2 _min, Vector2 _max, ref List<int> ind)
	{

		int aabbMinX = Math.Clamp(getIndex(_min.x), 0, gridWidth - 1);
		int aabbMinY = Math.Clamp(getIndex(_min.y), 0, gridHeight - 1);
		int aabbMaxX = Math.Clamp(getIndex(_max.x), 0, gridWidth - 1);
		int aabbMaxY = Math.Clamp(getIndex(_max.y), 0, gridHeight - 1);

		int aabbMin = getIndex1D(aabbMinX, aabbMinY);
		int aabbMax = getIndex1D(aabbMaxX, aabbMaxY);

		ind.Add(aabbMin);
		if (aabbMin != aabbMax)
		{
			ind.Add(aabbMax);
			int lenX = aabbMaxX - aabbMinX + 1;
			int lenY = aabbMaxY - aabbMinY + 1;
			for (int x = 0; x < lenX; x++)
			{
				for (int y = 0; y < lenY; y++)
				{
					if ((x == 0 && y == 0) || (x == lenX - 1 && y == lenY - 1))
						continue;
					ind.Add(getIndex1D(x, y) + aabbMin);
				}
			}
		}
	}

  /* DDA line algorithm. @author playchilla.com */
	public List<int> lineToGrid(float x1, float y1, float x2, float y2)
	{
		var arr = new List<int>();

		int gridPosX = getIndex(x1);
		int gridPosY = getIndex(y1);

		if (!isValidGridPos(gridPosX) || !isValidGridPos(gridPosY))
			return arr;

		arr.Add(getIndex1D(gridPosX, gridPosY));

		float dirX = x2 - x1;
		float dirY = y2 - y1;
		float distSqr = dirX * dirX + dirY * dirY;
		if (distSqr < 0.00000001)// todo: use const epsilon
			return arr;

		float nf = (float)(1 / Math.Sqrt(distSqr));
		dirX *= nf;
		dirY *= nf;

		float deltaX = cellSize / Math.Abs(dirX);
		float deltaY = cellSize / Math.Abs(dirY);

		float maxX = gridPosX * cellSize - x1;
		float maxY = gridPosY * cellSize - y1;
		if (dirX >= 0)
			maxX += cellSize;
		if (dirY >= 0)
			maxY += cellSize;
		maxX /= dirX;
		maxY /= dirY;

		int stepX = Math.Sign(dirX);
		int stepY = Math.Sign(dirY);
		int gridGoalX = getIndex(x2);
		int gridGoalY = getIndex(y2);
		int currentDirX = gridGoalX - gridPosX;
		int currentDirY = gridGoalY - gridPosY;

		while (currentDirX * stepX > 0 || currentDirY * stepY > 0)
		{
			if (maxX < maxY)
			{
				maxX += deltaX;
				gridPosX += stepX;
				currentDirX = gridGoalX - gridPosX;
			}
			else
			{
				maxY += deltaY;
				gridPosY += stepY;
				currentDirY = gridGoalY - gridPosY;
			}

			if (!isValidGridPos(gridPosX) || !isValidGridPos(gridPosY))
				break;

			arr.Add(getIndex1D(gridPosX, gridPosY));
		}
		return arr;
	}

	public void clear()
	{
		for (var cell in grid)
		{
			if (cell.Count > 0)
			{
				for (var co in cell)
				{
					co.gridIndex.Clear();
				}
				cell.Clear();
			}
		}
	}

	public int cellSize { get; set; }

  /* the world space width */
	public int gridWidth { get; set; }

  /* the world space height */
	public int gridHeight { get; set; }

  /* the number of buckets (i.e. cells) in the spatial grid */
	public int gridLength { get; set; }
  /* the array-list holding the spatial grid buckets */
	public List<List<T>> grid { get; set; }
}