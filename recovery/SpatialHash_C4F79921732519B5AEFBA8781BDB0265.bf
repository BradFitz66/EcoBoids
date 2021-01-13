using System;
using System.Collections;
using static raylib_beef.Raymath;
using raylib_beef.Types;
namespace Boids.lib
{
	class SpatialHash<T> where T:Entity
	{
		float gridHeightRes;
		float gridWidthRes;
		double invCellSize;
		int cellSize;
		int gridWidth;
		int gridHeight;
		int gridLength;
		List<List<T>> grid ~ DeleteContainerAndItems!(_);


		public this(int _width, int _height, int _cellSize){
			gridWidthRes=_width;
			gridHeightRes=_height;

			cellSize=_cellSize;
			invCellSize=double(1/cellSize);

			gridWidth=(int)Math.Ceiling(_width*invCellSize);
			gridHeight=(int)Math.Ceiling(_height*invCellSize);

			gridLength=gridWidth*gridHeight;

			grid=new List<List<T>>();

			for(int i=0; i<gridLength; i++){
				grid.Add(new List<T>());
			}
		}

		public void Add(T entity){
			
		}

		void AddIndex(T entity, int _cellPos){
			grid[_cellPos].Add(entity);
			
		}
	}
}
