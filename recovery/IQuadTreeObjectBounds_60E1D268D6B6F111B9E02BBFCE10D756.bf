namespace Boids.lib.QuadTree
{
	public interface IQuadTreeObjectBounds<T>
	{
	    /// <summary>Gets the x-coordinate of the left edge of the object.</summary>
	    double GetLeft(T obj);
	    /// <summary>Gets the x-coordinate of the right edge of the object.</summary>
	    double GetRight(T obj);
	    /// <summary>Gets the y-coordinate of the top edge of the object.</summary>
	    double GetTop(T obj);
	    /// <summary>Gets the y-coordinate of the bottom edge of the object.</summary>
	    double GetBottom(T obj);
	}
}
