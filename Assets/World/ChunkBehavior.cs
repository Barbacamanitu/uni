using System.Collections;
using System.Collections.Generic;
using UnityEngine;





public class ChunkBehavior : MonoBehaviour
{
    private int nmod(int k, int n) { return ((k %= n) < 0) ? k + n : k; }
    
    public Vector3Int position;
    public Texture2D heightmap;
    public int chunkSize;
    private int[] chunkData;
    private ComputeBuffer voxelBuffer;
    private ComputeBuffer vertBuffer;
    private ComputeBuffer quadCountBuffer;

    private ComputeBuffer triBuffer;
    private int voxelKernel;
    private int meshKernel;
    private ComputeShader voxelShader;
    private int posToIndex(Vector3Int pos)
    {
        int x = nmod(pos.x, chunkSize);
        int y = nmod(pos.y, chunkSize);
        int z = nmod(pos.z, chunkSize);
        return (x * chunkSize * chunkSize) + (y * chunkSize) + z;
    }

    private Vector3Int indexToPos(int i)
    {
        int x = i / (chunkSize * chunkSize);
        i -= (x*chunkSize*chunkSize);
        int y = i / chunkSize;
        i -= (y*chunkSize);
        int z = i;
        return new Vector3Int(x, y, z);
    }
    // Start is called before the first frame update
    void Start()
    {
        InitChunk();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void InitChunk()
    {
        int vCount = chunkSize * chunkSize * chunkSize;
        chunkData = new int[vCount];
        voxelShader = Resources.Load<ComputeShader>("VoxelCompute");
        voxelKernel = voxelShader.FindKernel("VoxelFromHeightmap");
        meshKernel = voxelShader.FindKernel("VoxelToMesh");
        voxelBuffer = new ComputeBuffer(vCount, sizeof(int));
        vertBuffer = new ComputeBuffer(vCount, sizeof(float) * 3, ComputeBufferType.Append);
        quadCountBuffer = new ComputeBuffer(1, sizeof(int));
        vertBuffer.SetCounterValue(0);
        voxelShader.SetInt("chunkSize", chunkSize);
        voxelShader.SetTexture(voxelKernel, "heightmap", heightmap);
        voxelShader.SetBuffer(voxelKernel, "voxelBuffer", voxelBuffer);
       
        voxelShader.Dispatch(voxelKernel, chunkSize/4, chunkSize/4, chunkSize/4);
        voxelShader.SetBuffer(meshKernel, "voxelBuffer", voxelBuffer);
        voxelShader.SetBuffer(meshKernel, "vertBuffer", vertBuffer);
        voxelShader.SetBuffer(meshKernel, "quadCountBuffer", quadCountBuffer);
        Camera mCam = Camera.main;
        Vector3 cPos = mCam.transform.position;
        Vector3 cDir = mCam.transform.forward;
        voxelShader.SetVector("cameraPos", cPos);
        voxelShader.SetVector("cameraDir", cDir);
        voxelShader.Dispatch(meshKernel, chunkSize / 4, chunkSize / 4, chunkSize / 4);


        int quadCount;
        int[] q = new int[1];
        ComputeBuffer.CopyCount(voxelBuffer, quadCountBuffer, 0);
        quadCountBuffer.GetData(q);
        quadCount = q[0];
        Vector3[] verts = new Vector3[quadCount];
        vertBuffer.GetData(verts, 0, 0, quadCount);
        var mr = GetComponent<MeshFilter>();
        Mesh m = new Mesh();
        mr.mesh = m;
        m.Clear();
        m.vertices = verts;
        List<int> tris = new List<int>();
        for (int i = 0; i < quadCount; i++)
        {
            tris.Add(i);
            tris.Add(i);
            tris.Add(i);
        }
        m.triangles = tris.ToArray();

       
        
    }
}
