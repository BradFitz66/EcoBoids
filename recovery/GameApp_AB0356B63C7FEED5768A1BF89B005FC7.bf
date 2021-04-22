using System;
using System.Collections;
using System.Threading;
using static raylib_beef.Raylib;
using raylib_beef.Types;
using static raylib_beef.Raymath;

using Boids.lib;
using System.Diagnostics;


/*
	Title: GameApp
	Description: Handles initialization of boids and updating of systems like the spatial hash as-well as handling the
drawing
*/
namespace Boids
{
	//Global stuff
	static
	{
		public static GameApp app;
		public static bool Paused = false;
		public static Camera2D cam;

		public static bool DebugView = true;

		public static SpatialHash<Entity> hash;

		public static uint32 hashNumbers(int8 a, int8 b, int8 c)
		{
			uint32 hash = ((uint32)a << 16) + ((uint32)b << 8) + (uint32)c;
			return hash;
		}


		//Width and height of the screen when first created. This is used to calculate screen relative positions for UI
		// elements.
		public const int baseScreenWidth = 1200;
		public const int baseScreenHeight = 720;

		public const int worldWidth = 2000;
		public const int worldHeight = 2000;


		public const int BoidsAmount = 250;
		public const int FlockAmount = 10;
		public const int maxPredatorCount = 10;
		public static void SetCameraTarget(Boid newTarget)
		{
			app.camTarg = newTarget;
		}
		public static void DisplayGenerationStats(Boid target)
		{
			Console.WriteLine("!");
			app.ShowingStatsOf = target;
		}
	}

	class GameApp
	{
		public Boid camTarg = null;
		public Boid ShowingStatsOf;
		public List<Flock> flocks ~ delete _;

		MainMenu m;
		float zoomLevel = 1.0f;
		float camSpeed = 6;
		bool inGame = false;
		float defaultCamSpeed = 6;
		Flock predators;
		Stopwatch keyPressDebounce;
		Button minimizeButton ~ delete _;
		bool flockStatsMinimized = false;



		public this()
		{
			app = this;
			m = new MainMenu();
			keyPressDebounce = new .()..Start();
		}

		public ~this()
		{
			DeleteAndNullify!(hash);
		}

		public void Init()
		{
			//Initialize simulation
			inGame = true;

			cam = Camera2D(.(0, 0), .(0, 0), 0, 1);

			minimizeButton = new Button(.(200, 0), .(100, 20), Color.RAYWHITE, "");
			minimizeButton.TextField.fontSize = 24;

			minimizeButton.onClick.Add(new () => { Debug.WriteLine("AAA"); flockStatsMinimized = !flockStatsMinimized; });
			hash = new SpatialHash<Entity>(100);

			predators = new Flock(maxPredatorCount, worldWidth / 2, worldHeight / 2, 1000, true);
			predators.flockMixColor = Color.RED;

			flocks = new List<Flock>();

			for (int i = 0; i < FlockAmount; i++)
			{
				float randx = rand.Next(0, worldWidth);
				float randy = rand.Next(0, worldHeight);
				let f = new Flock(BoidsAmount / FlockAmount, randx, randy, 100);
				flocks.Add(f);
			}
			flocks.Add(predators);
		}

		public void ShowGenerationStats()
		{
			if (ShowingStatsOf == null)
				return;
			let genStats = ShowingStatsOf.boidStats.previousGenerationStats;


			for (int j = 0; j < genStats.Count; j++)
			{
				DrawText(scope $"Generation {j+1}:", GetScreenWidth() - 200, 0 + int32(80 * j), 14, Color.BLACK);
				DrawText(scope $"Speed:{genStats[j].maxSpeed}", GetScreenWidth() - 150, int32(20 + (80 * j)), 14, Color.BLACK);
				DrawText(scope $"Force:{genStats[j].maxForce}", GetScreenWidth() - 150, int32(40 + (80 * j)), 14, Color.BLACK);
				DrawText(scope $"Max age:{genStats[j].maxAge}", GetScreenWidth() - 150, int32(60 + (80 * j)), 14, Color.BLACK);
			}
		}

		public int32 GetScreenHeightWithZoom()
		{
			return int32(GetScreenHeight() * (1 / Math.Abs(zoomLevel)));
		}
		public int32 GetScreenWidthWithZoom()
		{
			return int32(GetScreenWidth() * (1 / Math.Abs(zoomLevel)));
		}
		public void Update()
		{

			//Only update main menu if not in game
			if (!inGame)
			{
				m.Update();
				return;
			}

			minimizeButton.Update();


			camSpeed = IsKeyDown(raylib_beef.Enums.KeyboardKey.KEY_LEFT_SHIFT) ? defaultCamSpeed * 2 : defaultCamSpeed;
			if (camTarg != null)
			{
				cam.target.x = camTarg.position.x - (GetScreenWidthWithZoom() / 2);
				cam.target.y = camTarg.position.y - (GetScreenHeightWithZoom() / 2);
			}

			if (IsKeyDown(.KEY_BACKSPACE))
			{
				ShowingStatsOf = null;
			}

			if (IsKeyDown(raylib_beef.Enums.KeyboardKey.KEY_A))
			{
				cam.target += .(-1, 0) * (camSpeed + (1 / zoomLevel));
				camTarg = null;
			}
			if (IsKeyDown(raylib_beef.Enums.KeyboardKey.KEY_D))
			{
				cam.target += .(1, 0) * (camSpeed + (1 / zoomLevel));
				camTarg = null;
			}
			if (IsKeyDown(raylib_beef.Enums.KeyboardKey.KEY_W))
			{
				cam.target += .(0, -1) * (camSpeed + (1 / zoomLevel));
				camTarg = null;
			}
			if (IsKeyDown(raylib_beef.Enums.KeyboardKey.KEY_S))
			{
				cam.target += .(0, 1) * (camSpeed + (1 / zoomLevel));
				camTarg = null;
			}
			if (camTarg == null)
			{
				if (cam.target.x > (worldWidth - GetScreenWidthWithZoom()))
				{
					cam.target.x = worldWidth - GetScreenWidthWithZoom();
				}
				else if (cam.target.x < 0)
				{
					cam.target.x = 0;
				}

				if (cam.target.y > worldHeight - GetScreenHeightWithZoom())
				{
					cam.target.y = worldHeight - GetScreenHeightWithZoom();
				}
				else if (cam.target.y < 0)
				{
					cam.target.y = 0;
				}
			}
			zoomLevel += GetMouseWheelMove() * 0.05f;
			if (zoomLevel < 0.25f)
				zoomLevel = 0.25f;
			else if (zoomLevel > 1.5f)
				zoomLevel = 1.5f;
			cam.zoom = zoomLevel;

			minimizeButton.TextField.Text = !flockStatsMinimized ? "Minimize" : "Maximize";

			if (!Paused)
			{
				for (int i = 0; i < flocks.Count; i++)
				{
					flocks[i].Update();
				}
			}

			if (IsKeyDown(raylib_beef.Enums.KeyboardKey.KEY_P) && keyPressDebounce.Elapsed.TotalMilliseconds > 500)
			{
				Paused = !Paused;
				keyPressDebounce.Restart();
			}
		}

		public int GetBoidAmount()
		{
			int boidCount = 0;

			for (int i = 0; i < flocks.Count; i++)
			{
				boidCount += flocks[i].boids.Count;
			}

			return boidCount;
		}

		public void Draw()
		{
			//Draw everything

			ClearBackground(.(255, 255, 255, 255));
			if (!inGame)
			{
				m.Draw();
				return;
			}

			BeginMode2D(cam);
			if (inGame)
			{
				for (int i = 0; i < flocks.Count; i++)
				{
					flocks[i].Draw();
				}
			}
			if (DebugView)
				hash.Draw();
			EndMode2D();

			//UI drawing
			if (!flockStatsMinimized)
			{
				for (int i = 0; i < flocks.Count; i++)
				{
					if (flocks[i].flockMixColor == .RED)
						continue;
					DrawText(scope $"Flock {i+1}: {flocks[i].boids.Count}", 0, int32(0 + (20 * i)), 20, flocks[i].flockColor);
				}
			}
			else
			{
				DrawText(scope $"Boids amount: {GetBoidAmount()}", 0, 0, 20, Color.BLACK);
			}

			if (ShowingStatsOf != null)
				ShowGenerationStats();
			minimizeButton.Draw();

			if (Paused)
				DrawText("Simulation paused", GetScreenWidth() / 2, 0, 28, Color.BLACK);
		}
	}
}