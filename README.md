## About
This is a light-weight structural analysis program used to analyze the axial forces, shear forcs, and bending moments of a 3D-space frame structure. The program utilizes MATLAB's extensive matrix operation capabilities to perform structural analysis calculations using the [direct stiffness method](https://en.wikipedia.org/wiki/Direct_stiffness_method).

## Inputs

### General
The geometry, member property, and loading conditions of the structure shall be defined in the provided spreadsheet `inputSheet.xlsx`. It is strongly recommended that the metrix or imperial units remain consistent throughout all sheets of the input spreadsheet (i.e. if area `A` and force `F` are defined as <code>mm<sup>2</sup></code> and `kN` respectively, the elastic modulus should be defined in `GPa` or <code>kN/mm<sup>2</sup></code>).

### Node Property
`Node Property` sheet is used to define the points or nodes where structural members connect. The location of the nodes are defined in the global coordinate system `X`, `Y`, and `Z`. Node displacement and rotational restraints can be defined for each node by setting the value to `1` under the corresponding node and displacement/rotational axis. Initial node displacement and rotation, if any, is also defined on this sheet.

### Member Property
`Member Property` sheet is used to define the member properties of the structural frame member. The frame member must be connected to a `NEAR` and `FAR` node. Rotation about the local-axis of the member is possible to orientate the member's local coordinate system (LCS) with respect to the global coordinate system (GCS) is possible by setting adjusting the rotational angle `ANGLE`. The default LCS orientation is shown in Figure 1.

### Node Load
`Node Load` sheet is used to define any point load or point rotation applied directly on a node. `LOAD FACTOR` can be utilized to assign load factors (i.e. from a load combination).

### Span Load
`Span Load` sheet is used to define all point and uniformly distributed loads on a structural frame member. Six (6) load types (diagram explanation is included within the sheet) are supported. The loads in `X`, `Y`, and `Z` directions can be projected to either GCS or LCS by setting the `LOAD PROJECTION` value to `1` and `2` respectively.

## Output

### Member End Results
`Member End Results` is the summary sheet showing the structrual analysis result of the selected member. Change the `member id` to review the end forces and moments. Raw data output from the program are provided in the subsequent sheets.
