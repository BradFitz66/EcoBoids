using System;
using static raylib_beef.Raylib;
using raylib_beef.Enums;
namespace Boids
{
	static{
		public static bool useSpatialHash=false;
	}
	class Program
	{
		static GameApp gApp;
		static void Main(String[] args){
			gApp=scope GameApp();
			SetConfigFlags(ConfigFlag.FLAG_WINDOW_RESIZABLE);
			InitWindow(11, 720, "Boids");
			SetTargetFPS(60);
			while (!WindowShouldClose())
			{
				DrawFPS(1150,720-50);
				gApp.Update();
				gApp.Draw();
			}
			CloseWindow();
		}
	}
}
