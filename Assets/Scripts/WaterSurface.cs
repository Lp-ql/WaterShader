using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class WaterSurface : MonoBehaviour
{
    #region Inspector Modifiable Fields
    [SerializeField]
    private Material material;

    [SerializeField]
    private float meshScale = 10;

    [SerializeField]
    private int meshSize = 200;
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

        for (int x = 0; x < meshSize; x++)
        {
            for (int z = 0; z < meshSize; z++)
            {
                var a = new Vector3(x, 0, z);
                var b = a + new Vector3(1, 0, 0);
                var c = a + new Vector3(1, 0, 1);
                var d = a + new Vector3(0, 0, 1);

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

        var vertices = vertexIndexMap.OrderBy(x => x.Value).Select(x => x.Key);
        mesh.vertices = vertices.Select(x => x * meshScale / meshSize).ToArray();
        mesh.uv = vertices.Select(UvMapping).ToArray();
        mesh.triangles = triangles.ToArray();
        mesh.RecalculateNormals();
        mesh.RecalculateTangents();
        waterMesh.mesh = mesh;
        meshRenderer.material = material;
    }

    private Vector2 UvMapping(Vector3 v)
    {
        Vector2 uv = new Vector2(Mathf.InverseLerp(0, meshSize - 1, v.x), Mathf.InverseLerp(0, meshSize - 1, v.z));
        return uv;
    }

    // Update is called once per frame
    void Update()
    {

    }
}
