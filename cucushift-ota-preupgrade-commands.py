import getopt
import json
import sys

def write_json_to_file(obj, output="sample.json"):
    """
    write json object to file
    
    Params:
        obj: json object
        output: the output file
    """
    
    json_object = json.dumps(obj, indent=4)
 
    with open(output, "w") as outfile:
        outfile.write(json_object)

def create_cincy_json(nodes: list, edges: list = []):
    """
    Create dummy cincy json
    
    Params:
        nodes: a list of dict object, for example:
            [
                {
                    "version": "4.17.0-0.nightly-2024-10-28-130315",
                    "payload": "registry.ci.openshift.org/ocp/release@sha256:351b4eb476837fadaed5773b21fc2811ea9fb15d2ed4bd38a2fdc012092bda21"
                }
            ]
        edges: a list of dict object, for example:
            [[0,1]]
    Returns:
        the prepared dummy cincy json 
    """
    
    cincy = {
    "nodes": [
    ],
    "edges": [
    ]
}
    if nodes:
        cincy["nodes"] = nodes
    if edges:
        cincy["edges"] = edges
    return cincy

if __name__ == "__main__":
    options = "n:e:o:"
    opts , args = getopt.getopt(sys.argv[1:], options)
    
    str_nodes, str_edges, output = None, None, ""
    for currentArgument, currentValue in opts:
        if currentArgument in ("-n", "--nodes"):
            str_nodes = currentValue.strip()
        if currentArgument in ("-e", "--edges"):
            str_edges = currentValue.strip()
        if currentArgument in ("-o", "--output"):
            output = currentValue.strip()
    
    print("str_nodes: ", str_nodes)
    print("str_edges: ", str_edges)
    nodes = json.loads(str_nodes) if str_nodes else None
    edges = json.loads(str_edges) if str_edges else None
    cincy = create_cincy_json(nodes=nodes, edges=edges)
    output = output if output else "sample.json"
    print("output: ", output)
    write_json_to_file(cincy, output=output)