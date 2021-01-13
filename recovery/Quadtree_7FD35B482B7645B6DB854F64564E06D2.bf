using System;
using System.Collections;

using System.IO;



namespace QuadTree
{
    /// <summary>
    ///     A node for a QuadTree using a List implementation.
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class QTreeNode<T>
    {
        private List<QTreeNode<T>> _children = new List<QTreeNode<T>>(4);

        /// <summary>
        ///     Creates a new QuadTree node
        /// </summary>
        /// <param name="parent">The parent node</param>
        public this(QTreeNode<T> parent)
        {
            Parent = parent;
        }

        /// <inheritdoc />
        /// <param name="parent">The parent node</param>
        /// <param name="content">The content at this node</param>
        public this(QTreeNode<T> parent, T content) : this(parent)
        {
            Content = content;
        }

        /// <summary>
        ///     Creates a new QuadTree node with the specfied content and no parent.
        /// </summary>
        /// <param name="content">The content at this node</param>
        public this(T content)
        {
            Content = content;
        }


        private this()
        {
        }


        public QTreeNode<T> Parent { get; set; }

        /// <summary>
        ///     The conent stored at this node
        /// </summary>

        public T Content { get; set; }

        /// <summary>
        ///     Indicates if this node has children
        /// </summary>

        public bool HasChildren => _children.Count > 0;

        /// <summary>
        ///     Returns the number of descendant nodes and this node.
        /// </summary>
    

        /// <summary>
        ///     Indicates that this node has no content and there are no child nodes
        /// </summary>
        public bool IsEmpty => _children.Count == 0 && Content == null;


        /// <summary>
        ///     Returns the child node located at the specified index
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public QTreeNode<T> Child(int index)
        {
       
                return _children[index];
            

        }



        /// <summary>
        ///     Fixes parent links after deserializing a json file into a tree.
        /// </summary>
        /// <param name="root"></param>
        private static void FixParentLinks(QTreeNode<T> root)
        {
            foreach (var child in root._children)
            {
                child.Parent = root;
                FixParentLinks(child);
            }
        }





        /// <summary>
        ///     Inserts a QTreeNode into this node. The inserted node becomes a child of this node.
        /// </summary>
        /// <param name="child">The child node to insert</param>
        public void Insert(QTreeNode<T> child)
        {
            if (_children.Count < 4)
            {
                _children.Add(child);
                child.Parent = this;
            }
        }

        /// <summary>
        ///     Removes the child at the specified index and returns it
        /// </summary>
        /// <param name="index">The index of the child to remove</param>
        /// <returns></returns>
        public QTreeNode<T> RemoveAt(int index)
        {
            var item = _children[index];
            _children.RemoveAt(index);
            return item;
        }

        /// <summary>
        /// Returns a collection of lists containaing nodes at each level in the tree.
        /// </summary>
        /// <returns></returns>
        public List<List<QTreeNode<T>>> GetNodeLevels()
        {
            
            var levels = new List<List<QTreeNode<T>>>();
            var level = new List<QTreeNode<T>>();

            var queue = new Queue<QTreeNode<T>>();
            
            
            queue.Enqueue(this);

            while (queue.Count > 0)
            {
                var levelNodes = queue.Count;
                while (levelNodes > 0)
                {
                    var node = queue.Dequeue();
                    foreach (var child in node._children)
                    {
                        queue.Enqueue(child);
                    }
                    levelNodes--;
                    level.Add(node);
                    if (levelNodes == 0)
                    {
                        levels.Add(level);
                        level = new List<QTreeNode<T>>();

                    }

                }
            }
            return levels;

            
        }

      
    }
}