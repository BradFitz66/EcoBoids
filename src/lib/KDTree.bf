using System;
using System.Collections;
using raylib_beef.Types;
using static raylib_beef.Raylib;
using static raylib_beef.Raymath;

namespace Boids.lib
{

	/*
	Bad port of https://gist.github.com/ditzel/194ec800053ce7083b73faa1be9101b0
        i have no idea what I'm doing 
	*/
	public class KDTree<T> : IEnumerable<T> where T : Entity
	{
	    protected KdNode _root  ~ delete _;
	    protected KdNode _last ~ delete _;
	    protected int _count;
	    protected bool _just2D;
	    protected float _LastUpdate = -1f;
	    protected KdNode[] _open ~ delete _;

	    public int Count { get { return _count; } }
	    public bool IsReadOnly { get { return false; } }

	    /// <summary>
	    /// create a tree
	    /// </summary>
	    /// <param name="just2D">just use x/z</param>
	    public this(bool just2D = false)
	    {
	        _just2D = just2D;
	    }

		public ~this(){
		}

		public IEnumerator<T> GetEnumerator()
		{
			return default;
		}

	    public T this[int key]
	    {
	        get
	        {
	            var current = _root;
	            for(var i = 0; i < key; i++)
	                current = current.next;
	            return current.component;
	        }
	    }

	    /// <summary>
	    /// add item
	    /// </summary>
	    /// <param name="item">item</param>
	    public void Add(T item)
	    {
			KdNode node = new KdNode() { component = item };
	        _add(node);
	    }

	    /// <summary>
	    /// find all objects that matches the given predicate
	    /// </summary>
	    /// <param name="match">lamda expression</param>
	    public KDTree<T> FindAll(Predicate<T> match)
	    {
	        var list = new KDTree<T>(_just2D);
			for(int i=0; i<Count; i++){
				list.Add(this[i]);
			}
	        return list;
	    }

	    /// <summary>
	    /// find first object that matches the given predicate
	    /// </summary>
	    /// <param name="match">lamda expression</param>
	    public T Find(Predicate<T> match)
	    {
	        var current = _root;
	        while (current != null)
	        {
	            if (match(current.component))
	                return current.component;
	            current = current.next;
	        }
	        return null;
	    }

	    /// <summary>
	    /// count all objects that matches the given predicate
	    /// </summary>
	    /// <param name="match">lamda expression</param>
	    /// <returns>matching object count</returns>
	    public int CountAll(Predicate<T> match)
	    {
	        int count = 0;
			for(int i=0; i<Count; i++)
	            if (match(this[i]))
	                count++;
	        return count;
	    }

	    /// <summary>
	    /// clear tree
	    /// </summary>
	    public void Clear()
	    {


	        //rest for the garbage collection
	        _root = null;
	        _last = null;
	        _count = 0;
	    }


	    /// <summary>
	    /// Update positions (if objects moved)
	    /// </summary>
	    public void UpdatePositions()
	    {
	        //save old traverse
	        var current = _root;
	        while (current != null)
	        {
	            current._oldRef = current.next;
	            current = current.next;
	        }

	        //save root
	        current = _root;

	        //reset values
	        Clear();

	        //read
	        while (current != null)
	        {
	            _add(current);
	            current = current._oldRef;
	        }
	    }

	    public List<T> ToList()
	    {
	        var list = new List<T>();
			for(int i=0; i<Count; i++){
				list.Add(this[i]);
			}
	        return list;
	    }

	    /// <summary>
	    /// Method to enable foreach-loops
	    /// </summary>


	    protected float _distance(Vector2 a, Vector2 b)
	    {
	        return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y);
	    }
	    protected float _getSplitValue(int level, Vector2 position)
	    {

	        return (level % 2 == 0) ? position.x : position.y;
	    }

	    private void _add(KdNode newNode)
	    {
	        _count++;
	        newNode.left = null;
	        newNode.right = null;
	        newNode.level = 0;
	        var parent = _findParent(newNode.component.position);

	        //set last
	        if (_last != null)
	            _last.next = newNode;
	        _last = newNode;

	        //set root
	        if (parent == null)
	        {
	            _root = newNode;
	            return;
	        }

	        var splitParent = _getSplitValue(parent);
	        var splitNew = _getSplitValue(parent.level, newNode.component.position);
	        
	        newNode.level = parent.level + 1;

	        if (splitNew < splitParent)
	            parent.left = newNode; //go left
	        else
	            parent.right = newNode; //go right
	    }

	    private KdNode _findParent(Vector2 position)
	    {
	        //travers from root to bottom and check every node
	        var current = _root;
	        var parent = _root;
	        while (current != null)
	        {
	            var splitCurrent = _getSplitValue(current);
	            var splitSearch = _getSplitValue(current.level, position);

	            parent = current;
	            if (splitSearch < splitCurrent)
	                current = current.left; //go left
	            else
	                current = current.right; //go right

	        }
	        return parent;
	    }

	    /// <summary>
	    /// Find closest object to given position
	    /// </summary>
	    /// <param name="position">position</param>
	    /// <returns>closest object</returns>
	    public T FindClosest(Vector2 position)
	    {
	        return _findClosest(position);
	    }

	    /// <summary>
	    /// Find close objects to given position
	    /// </summary>
	    /// <param name="position">position</param>
	    /// <returns>close object</returns>
	    public void FindClose(Vector2 position,ref List<T> list)
	    {
	        _findClosest(position, list);
	    }

	    protected T _findClosest(Vector2 position, List<T> traversed = null)
	    {
	        if (_root == null)
	            return null;

	        float nearestDist = float.MaxValue;
	        KdNode nearest = null;

	        if (_open == null || _open.Count < Count)
	            _open = new KdNode[Count];
	        for (int i = 0; i < _open.Count; i++)
	            _open[i] = null;

	        var openAdd = 0;
	        var openCur = 0;

	        if (_root != null)
	            _open[openAdd++] = _root;

	        while (openCur < _open.Count && _open[openCur] != null)
	        {
	            var current = _open[openCur++];
	            if (traversed != null)
	                traversed.Add(current.component);

	            var nodeDist = _distance(position, current.component.position);
	            if (nodeDist < nearestDist)
	            {
	                nearestDist = nodeDist;
	                nearest = current;
	            }

	            var splitCurrent = _getSplitValue(current);
	            var splitSearch = _getSplitValue(current.level, position);

	            if (splitSearch < splitCurrent)
	            {
	                if (current.left != null)
	                    _open[openAdd++] = current.left; //go left
	                if (Math.Abs(splitCurrent - splitSearch) * Math.Abs(splitCurrent - splitSearch) < nearestDist && current.right != null)
	                    _open[openAdd++] = current.right; //go right
	            }
	            else
	            {
	                if (current.right != null)
	                    _open[openAdd++] = current.right; //go right
	                if (Math.Abs(splitCurrent - splitSearch) * Math.Abs(splitCurrent - splitSearch) < nearestDist && current.left != null)
	                    _open[openAdd++] = current.left; //go left
	            }
	        }
			if(nearest!=null)
	        return nearest.component;
			return null;
	    }

	    private float _getSplitValue(KdNode node)
	    {
	        return _getSplitValue(node.level, node.component.position);
	    }

	    private IEnumerator<T> _getNodes()
	    {
	        KdNode<> current = _root;
	        while (current != null)
	        {
	            current = current.next;
			}
			return current;
	    }

	    protected class KdNode : IEnumerator<T>
	    {
	        public T component ;
	        public int level;
	        public KdNode left;
	        public KdNode right;
	        public KdNode next;
	        public KdNode _oldRef;
			public Result<T> GetNext()
			{
				return default;
			}
			public ~this(){
				
			}

	    }

	}
}
