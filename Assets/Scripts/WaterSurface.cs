using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class WaterSurface : MonoBehaviour
{
    #region Inspector Modifiable Fields
    [SerializeField]
    private Material material;
    #endregion
    
    private MeshFilter waterMesh;
    private MeshRenderer meshRenderer;

    // Use this for initialization
    void Start()
    {
        waterMesh = gameObject.AddComponent<MeshFilter>();
        meshRenderer = gameObject.AddComponent<MeshRenderer>();

        Mesh mesh = new Mesh();

        var vertexIndexMap = new Dictionary<Vector3, int>();
        int vertexCount = 0;

        var triangles = new List<int>();

        float scale = 0.0625f;
        for (int x = -100; x <= 100; x++)
        {
            for (int z = -100; z <= 100; z++)
            {
                var a = new Vector3(x, 0, z) * scale;
                var b = a + new Vector3(1, 0, 0) * scale;
                var c = a + new Vector3(1, 0, 1) * scale;
                var d = a + new Vector3(0, 0, 1) * scale;

                foreach (var v in new Vector3[] { a, b, c, d })
                {
                    if (!vertexIndexMap.ContainsKey(v))
                    {
                        vertexIndexMap.Add(v, vertexCount++);
                    }
                }

                triangles.Add(vertexIndexMap[a]);
                triangles.Add(vertexIndexMap[c]);
                triangles.Add(vertexIndexMap[b]);
                triangles.Add(vertexIndexMap[a]);
                triangles.Add(vertexIndexMap[d]);
                triangles.Add(vertexIndexMap[c]);
            }
        }

        mesh.vertices = vertexIndexMap.ToList().OrderBy(x => x.Value).Select(x => x.Key).ToArray();
        mesh.triangles = triangles.ToArray();
        mesh.RecalculateNormals();
        mesh.RecalculateTangents();
        waterMesh.mesh = mesh;
        meshRenderer.material = material;
    }

    // Update is called once per frame
    void Update()
    {

    }
}
