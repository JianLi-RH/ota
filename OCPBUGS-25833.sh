#!/bin/sh

curl -s 'https://api.openshift.com/api/upgrades_info/graph?arch=amd64&channel=stable-4.6' | jq '
  (.nodes | with_entries(.key |= tostring)) as $nodes_by_index |
  (
    [
      .edges[] |
      select($nodes_by_index[(.[0] | tostring)].version == "4.13.22")[1] |
      tostring |
      $nodes_by_index[.].version
    ]
  ) as $edges |
  (
    [
      .conditionalEdges[] |
      .risks as $r |
      .edges[] |
      select(.from == "4.13.22") |
      .to as $to |
      {to: $to, risks: ([$r[] | .name])}
    ]
  ) as $conditionalEdges |
  {
    edges: $edges,
    conditionalEdges: $conditionalEdges
  }'
