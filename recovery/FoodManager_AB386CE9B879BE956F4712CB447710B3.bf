using System.Diagnostics;
using Boids.lib;
using System.Collections;
using System;
using static raylib_beef.Raylib;
using static raylib_beef.Raymath;
using raylib_beef.Types;
namespace Boids
{
	public static{
		public static FoodManager foodManager;
	}


	class FoodManager
	{
		public Stopwatch foodSpawnTimer ~ delete _;
		public int spawnTime=60;

		public int maxFood=10;

		List<Food> foodList ~ DeleteContainerAndItems!(_);

		public this{
			foodManager=this;
			//why
			foodSpawnTimer=new .()..Start();
			foodList=new .();
			for(int i=0; i<maxFood; i++){
				SpawnNewFood();
			}
		}

		public void RemoveFood(Food f){
			foodList.Remove(f);
			hash.RemoveRadius(f,f.initialAmount)
			delete f;
		}

		public void Update(){
			if(foodList.Count==maxFood){
				foodSpawnTimer.Reset();
			}
			else{
				if(!foodSpawnTimer.IsRunning){
					foodSpawnTimer.Start();
				}
			}
			if(foodSpawnTimer.Elapsed.TotalSeconds>=spawnTime){
				SpawnNewFood();
				foodSpawnTimer.Restart();
			}
		}

		public void Draw(){
			for(int i=0; i<foodList.Count; i++){
				foodList[i].Draw();
			}
		}

		public void SpawnNewFood(){
			let r = scope Random();
			Food newFood=new Food(.(r.Next(100,worldWidth-100),r.Next(100,worldHeight-100)));
			foodList.Add(newFood);
		}

		public Food GetClosestFood(Boid b){
			float minDist=int.MaxValue;

			Food closest=null ;
			for(int i=0; i<foodList.Count; i++){
				float dist=Vector2Distance(foodList[i].position,b.position);
				if(dist<minDist && foodList[i].amount>0){
					minDist=dist;
					closest=foodList[i];
				}
			}
			return closest;
		}
	}
}
