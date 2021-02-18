using System;
using static raylib_beef.Raylib;
using raylib_beef.Enums;
namespace Boids
{
	static{
		public static bool useSpatialHash=false;
	}
	/*
	Title: Program
	Description: Entry point for the program. Initializes raylib and creates GameApp.
	*/
	class Program
	{
		static GameApp gApp;
		static void Main(String[] args){

			SetConfigFlags(ConfigFlag.FLAG_WINDOW_RESIZABLE);
			InitWindow(1200, 720, "Boids");
			SetTargetFPS(120);
			
			gApp=scope GameApp();
			while (!WindowShouldClose())
			{

				
				DrawFPS(GetScreenWidth()-90,GetScreenHeight()-50);
				gApp.Update();
				BeginDrawing();
				ClearBackground(.(255,255,255,255));
				gApp.Draw();
				EndDrawing();
			}
			CloseWindow();
		}
	}
}
