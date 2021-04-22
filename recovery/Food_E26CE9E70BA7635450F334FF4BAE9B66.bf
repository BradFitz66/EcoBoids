using Boids.lib;
using System;
using static raylib_beef.Raylib;
using raylib_beef.Types;
namespace Boids
{
	class Food : Entity 
	{
		public float amount=1;
		public float initialAmount;
		public this(Vector2 pos){
			position=pos;
			amount=scope Random().Next(20,50);
			initialAmount=amount;
			hash.AddRadius(this,initialAmount);
		}
		public override void Draw()
		{
			DrawCircleV(position,initialAmount,.(Color.SKYBLUE.r,Color.SKYBLUE.b,Color.SKYBLUE.b,uint8(255*(amountinitialAmount))));
		}

		public override void Update()
		{
			if(amount<=0)
				foodManager.RemoveFood(this);

			base.Update();
		}
	}
}
