using raylib_beef.Types;
using static raylib_beef.Raylib;
namespace Boids.lib
{
	class Point : Entity
	{
		public Vector2 prevPos;
		public this(Vector2 pos){
			prevPos=pos;
			position=pos;
		}
		public override void Draw()
		{
			DrawCircle((int32)position.x,(int32)position.y,10f,Color.RED);
		}
	}
}
