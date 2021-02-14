using System;
using static raylib_beef.Raylib;
using static raylib_beef.rlgl;
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
			InitWindow(1200, 720, "Boids");
			SetTargetFPS();
			while (!WindowShouldClose())
			{
				DrawFPS(GetScreenWidth()-90,GetScreenHeight()-50);
				gApp.Draw();
				gApp.Update();
			}
			CloseWindow();
		}
	}
}
