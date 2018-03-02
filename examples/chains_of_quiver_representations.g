LoadPackage( "QPA" );
LoadPackage( "ComplexesForCAP" );

DeclareOperation( "LinearQuiver", [ IsDirection, IsObject, IsInt, IsInt ] );
DeclareOperation( "LinearRightQuiver", [ IsObject, IsInt, IsInt ] );
DeclareOperation( "LinearLeftQuiver", [ IsObject, IsInt, IsInt ] );
DeclareOperation( "ArrowsBetweenTwoVertices", [ IsVertex, IsVertex ] );

InstallMethod( LinearQuiver, 
	[ IsDirection, IsObject, IsInt, IsInt ],
  function( d, k, m, n )
    local L, kL, c, l, constructor;
    if d = RIGHT then 
      	constructor := "RightQuiver";
    else
        constructor := "LeftQuiver";
    fi;

    if m<=n then
    	L := ValueGlobal(constructor)(  Concatenation( "L(v", String(m), ")[d", String(m), "]" ), n - m + 1, 
    		List( [ m .. n - 1 ], i-> [ Concatenation( "v", String(i) ), Concatenation( "v", String(i+1) ) ]  ) );
    	kL := PathAlgebra( k, L );
    	c := ArrowLabels( L );
    	l := List( [ 1 .. Length( c )-1 ], i -> [ c[i], c[i+1] ] );
	if d = RIGHT then
    	    l := List( l, label -> PrimitivePathByLabel( L, label[1] )*PrimitivePathByLabel( L, label[2] ) );
	else
	    l := List( l, label -> PrimitivePathByLabel( L, label[2] )*PrimitivePathByLabel( L, label[1] ) );
	fi;
    	l := List( l, r -> QuiverAlgebraElement( kL, [1], [r] ) );
    	return [ L, kL, l ];
    else
        L := ValueGlobal(constructor)(  Concatenation( "L(v", String(n), ")[d", String(n+1), "]" ), m - n + 1,
	        List( [ n .. m - 1 ], i-> [ Concatenation( "v", String(i+1) ), Concatenation( "v", String(i) ) ]  ) );
        kL := PathAlgebra( k, L );
	c := ArrowLabels( L );
	l := List( [ 1 .. Length( c )-1 ], i -> [ c[i+1], c[i] ] );
	if d = RIGHT then
	    l := List( l, label -> PrimitivePathByLabel( L, label[1] )*PrimitivePathByLabel( L, label[2] ) );
	else 
	    l := List( l, label -> PrimitivePathByLabel( L, label[2] )*PrimitivePathByLabel( L, label[1] ) );
	fi;
	l := List( l, r -> QuiverAlgebraElement( kL, [1], [r] ) );
	L!.("m") := m;
	L!.("n") := n;
	return [ L, kL, l ];
    fi;
end );

InstallMethod( LinearRightQuiver, 
	[ IsObject, IsInt, IsInt ],
  function( k, m, n )
    return LinearQuiver( RIGHT, k, m, n );
end );

InstallMethod( LinearLeftQuiver, 
	[ IsObject, IsInt, IsInt ],
  function( k, m, n )
    return LinearQuiver( LEFT, k, m, n );
end );

InstallMethod( ArrowsBetweenTwoVertices, 
		[ IsVertex, IsVertex ],
  function( v1, v2 )
    return Intersection( OutgoingArrows( v1 ), IncomingArrows( v2 ) );
end );

# DeclareOperation( "StackMatricesDiagonally", [ IsQPAMatrix, IsQPAMatrix ] );
# DeclareOperation( "StackMatricesDiagonally", [ IsDenseList ] );
# 

# InstallMethod( StackMatricesDiagonally, 
#                 [ IsQPAMatrix, IsQPAMatrix ],
#  function( M1, M2 )
#  local d1,d2,F, M1_, M2_; 
# 
#  d1 := DimensionsMat( M1 );
#  d2 := DimensionsMat( M2 );
# 
#  if d1[1]*d1[2] = 0 then return M2;fi;
#  if d2[1]*d2[2] = 0 then return M1;fi;
# 
#  F := BaseDomain( M1 );
#  if F <> BaseDomain( M2 ) then
#     Error( "matrices over different rings" );
#  fi;
# 
#  M1_ := StackMatricesHorizontally( M1, MakeZeroMatrix( F, d1[1], d2[2] ) );
#  M2_ := StackMatricesHorizontally( MakeZeroMatrix( F, d2[1], d1[2] ), M2 );
#  return StackMatricesVertically( M1_, M2_ );
# end );
# 
# InstallMethod( StackMatricesDiagonally, [ IsDenseList ],
# function( matrices )
#   return Iterated( matrices, StackMatricesDiagonally );
# end );


# f := function( q, kq, rel, m, n )
#  local quiver, kquiver, c, l, rel1, rel2, L, arrows, paths;
#  L := LinearRightQuiver( m, n );
#  quiver := QuiverProduct( L, q );
#  kquiver := PathAlgebra( LeftActingDomain( kq ), quiver );
#  c := ArrowLabels( L );
#  l := Concatenation( List( [ 1 .. Length(c)-1], i -> List( VertexLabels( q ), j -> [ [ c[i], j ], [ c[i+1], j ] ] ) ) );
#  l := List( l, label -> PrimitivePathByLabel( quiver, label[1] )*PrimitivePathByLabel( quiver, label[2] ) );
#  rel1 := List( l, r -> QuiverAlgebraElement( kquiver, [1], [r] ) );
#  c := VertexLabels( L );
#  l := Concatenation( List( [ 1 .. Length(c)-1], i -> List( ArrowLabels( q ), j -> [ [ c[i], j ], [ c[i+1], j ] ] ) ) );
#  l := List( l, label -> [ PrimitivePathByLabel( quiver, label[1] ), PrimitivePathByLabel( quiver, label[2] ) ] );
#  l := List( l, arrows -> [ arrows[1]*ArrowsBetweenTwoVertices( Target( arrows[1] ), Target( arrows[2] ) )[1], 
#       				ArrowsBetweenTwoVertices( Source( arrows[1] ), Source( arrows[2] ) )[1]*arrows[2] ] );
#  rel2 := List( l, paths-> QuiverAlgebraElement( kquiver, [ 1, -1 ], paths ) );
#  if rel=[] then return [ quiver, kquiver, Concatenation( rel1, rel2 ) ] ;fi;
#  paths := List( rel, r -> [ Coefficients( r ), Paths( r ) ] );
#  arrows := List( paths, p -> [ p[1], List( p[2], path -> ArrowList( path ) ) ] );
#  l := Concatenation( List( Vertices( L ), v -> List( arrows, p -> [ p[1], List( p[2], l -> List( l, u-> [ Label(v), Label(u) ] ) ) ] ) ) );
#  l := List( l, u -> [ u[1], List( u[2], l-> Product( List( l, label->PrimitivePathByLabel( quiver, label ) ) ) )] );
#  l := DuplicateFreeList( List( l, h-> QuiverAlgebraElement( kquiver, h[1], h[2] ) ) );
#  l := Filtered( l, u-> not IsZero(u) );
#  return [ quiver, kquiver, Concatenation( l, rel1, rel2 ) ];
# end;

# q := RightQuiver( "q(0)[a]", 2, [ [ 0, 1 ], [ 1, 0 ] ] );
# p := f(q, -2, 5 );
# A := QuotientOfPathAlgebra( last, p );
# QuotientOfPathAlgebraElement( A, p[1] );
# { 0 }

product_of_algebras := function( Aq, m, n )
    local k, Lmn, AL;
    k := LeftActingDomain( Aq );
    Lmn := LinearRightQuiver( k, m, n );
    if Lmn[3] = [ ] then 
        AL := Lmn[2];
    else
        AL := QuotientOfPathAlgebra( Lmn[2], Lmn[3] );
    fi;
    return TensorProductOfAlgebras( AL, Aq );
end;

convert_chain_or_cochain_to_representation := 
    function( C, A  )
    local L, m, n, Q, dimension_vector, matrices1, matrices2, matrices; 
    
    L := QuiverOfAlgebra( TensorProductFactors( A )[1] );
    m := ShallowCopy( Label( Vertex( L, 1 ) ) );
    RemoveCharacters( m, "v" );
    m := Int(m);
    n := m + NumberOfVertices( L ) - 1;
    if IsChainComplex( C ) then
        Q := QuiverOfAlgebra( A );
        dimension_vector := Concatenation( List( [ m .. n ], i-> DimensionVector( C[ i ] ) ) );
        matrices1 := Concatenation( List( [ m .. n ], i -> MatricesOfRepresentation( C[ i ] ) ) );
        matrices2 := Concatenation( List( [ m + 1 .. n ], i-> MatricesOfRepresentationHomomorphism( C^i ) ) );
        matrices := Concatenation( matrices1, matrices2 );
        return QuiverRepresentation( A, dimension_vector, Arrows( Q ), matrices );   
    else
        Q := QuiverOfAlgebra( A );
        dimension_vector := Concatenation( List( [ m .. n ], i-> DimensionVector( C[ i ] ) ) );
        matrices1 := Concatenation( List( [ m .. n ], i -> MatricesOfRepresentation( C[ i ] ) ) );
        matrices2 := Concatenation( List( [ m .. n - 1 ], i-> MatricesOfRepresentationHomomorphism( C^i ) ) );
        matrices := Concatenation( matrices1, matrices2 );
        return QuiverRepresentation( A, dimension_vector, Arrows( Q ), matrices );
    fi;
    
end;

convert_chain_or_cochain_mor_to_representation_mor :=
    function( phi, A )
    local L,m,n, matrices, r1, r2;
    L := QuiverOfAlgebra( TensorProductFactors( A )[1] );
    m := ShallowCopy( Label( Vertex( L, 1 ) ) );
    RemoveCharacters( m, "v" );
    m := Int(m);
    n := m + NumberOfVertices( L ) - 1;
    matrices := Concatenation( List( [ m .. n ], i -> MatricesOfRepresentationHomomorphism( phi[ i ] ) ) );
    r1 := convert_chain_or_cochain_to_representation( Source( phi ), A );
    r2 := convert_chain_or_cochain_to_representation( Range( phi ), A );
    return QuiverRepresentationHomomorphism( r1, r2, matrices );
end;
    

convert_rep_mor_to_complex_mor := 
    function( C1, C2, mor, A )
    local Q, L, q, m, n, mats; 
    # Do the compatibility stuff
    Q := QuiverOfAlgebra( A );
    L := QuiverOfAlgebra( TensorProductFactors( A )[1] );
    q := QuiverOfAlgebra( TensorProductFactors( A )[2] );
    m := ShallowCopy( Label( Vertex( L, 1 ) ) );
    RemoveCharacters( m, "v" );
    m := Int(m);
    n := m + NumberOfVertices( L ) - 1;
#     maps := MatricesOfRepresentationHomomorphism( mor );
    mats := MatricesOfRepresentationHomomorphism( mor );
    mats := List( [ 1 .. NumberOfVertices( L ) ], 
                i -> List( [ 1 .. NumberOfVertices( q ) ],
                        j-> mats[ (i-1)*NumberOfVertices( q ) + j ] ) );
    mats := List( [ m .. n ], k -> QuiverRepresentationHomomorphism( C1[k], C2[k], mats[k-m+1] ) );
    if IsChainComplex( C1 ) then 
        return ChainMorphism( C1, C2, mats, m );
    else
        return CochainMorphism( C1, C2, mats, m );
    fi;
end;

basis_of_hom := 
    function( C1, C2 )
    local m, n, A, R1, R2, B; 
    
    m := Minimum( ActiveLowerBound( C1 ), ActiveLowerBound( C2 ) ) + 1;
    n := Maximum( ActiveUpperBound( C1 ), ActiveUpperBound( C2 ) ) - 1;
    if IsChainComplex( C1 ) then
        A := product_of_algebras( AlgebraOfRepresentation( C1[m] ), n, m );
    else
        A := product_of_algebras( AlgebraOfRepresentation( C1[m] ), m, n );
    fi;
    R1 := convert_chain_or_cochain_to_representation( C1, A );
    R2 := convert_chain_or_cochain_to_representation( C2, A );
    B := BasisOfHom( R1, R2 );
    return List( B, mor -> convert_rep_mor_to_complex_mor( C1, C2, mor, A ) );
end;

compute_lift_in_quiver_rep := 
    function( f, g )
    local homs_basis, Q, k, V, homs_basis_composed_with_g, L, vector, mat, sol, lift, h;
    
    homs_basis := BasisOfHom( Source( f ), Source( g ) );
    Q := QuiverOfRepresentation( Source( f ) );
    k := LeftActingDomain( AlgebraOfRepresentation( Source( f ) ) );
    V := Vertices( Q );
    homs_basis_composed_with_g := List( homs_basis, m -> PreCompose( m, g ) );
    L := List( V, v -> Concatenation( [ MatrixOfLinearTransformation( MapForVertex( f, v ) ) ],
                                        List( homs_basis_composed_with_g, h -> MatrixOfLinearTransformation( MapForVertex( h, v ) ) ) ) );
    L := List( L, l ->  List( l, m -> MatrixByCols( k, [ Concatenation( ColsOfMatrix( m ) ) ] ) ) );

    L := List( TransposedMat( L ), l -> StackMatricesVertically( l ) );
    vector := RowVector( k, ColsOfMatrix( L[ 1 ] )[ 1 ] );
    mat := TransposedMat( StackMatricesHorizontally( List( [ 2 .. Length( L ) ], i -> L[ i ] ) ) );

    sol := SolutionMat( mat, vector );
 
    if sol = fail then 
        return fail;
    else
    sol := sol!.entries;
    lift := ZeroMorphism( Source( f ), Source( g ) );
    for h in homs_basis do
         if not IsZero( sol[ 1 ] ) then
             lift := lift + sol[ 1 ]*h;
         fi;
    Remove( sol, 1 );
    od;
    fi;
    return lift;
end;

compute_colift_in_quiver_rep := 
    function( f, g )
    local homs_basis, Q, k, V, homs_basis_composed_with_f, L, vector, mat, sol, colift, h;
    
    homs_basis := BasisOfHom( Range( f ), Range( g ) );
    Q := QuiverOfRepresentation( Source( f ) );
    k := LeftActingDomain( AlgebraOfRepresentation( Source( f ) ) );
    V := Vertices( Q );
    homs_basis_composed_with_f := List( homs_basis, m -> PreCompose( f, m ) );
    L := List( V, v -> Concatenation( [ MatrixOfLinearTransformation( MapForVertex( g, v ) ) ],
                                        List( homs_basis_composed_with_f, h -> MatrixOfLinearTransformation( MapForVertex( h, v ) ) ) ) );
    L := List( L, l ->  List( l, m -> MatrixByCols( k, [ Concatenation( ColsOfMatrix( m ) ) ] ) ) );

    L := List( TransposedMat( L ), l -> StackMatricesVertically( l ) );
    vector := RowVector( k, ColsOfMatrix( L[ 1 ] )[ 1 ] );
    mat := TransposedMat( StackMatricesHorizontally( List( [ 2 .. Length( L ) ], i -> L[ i ] ) ) );
    sol := SolutionMat( mat, vector );

    if sol = fail then 
     return fail;
    else
    sol := sol!.entries;
    colift := ZeroMorphism( Range( f ), Range( g ) );
    for h in homs_basis do
        if not IsZero( sol[ 1 ] ) then
            colift := colift + sol[ 1 ]*h;
        fi;
    Remove( sol, 1 );
    od;
     
    fi;
    return colift;
end;


dual_functor := 
    function( cat )
    local A, Q, A_op, Q_op, cat_op, dual, cat_of_op_quiver; 
    
    cat_op := Opposite( cat );
    A := AlgebraOfCategory( cat );
    Q := QuiverOfAlgebra( A );
    A_op := OppositeAlgebra( A );
    Q_op := QuiverOfAlgebra( A_op );
    cat_of_op_quiver := CategoryOfQuiverRepresentations( A_op );
    dual := CapFunctor( "Dual functor", cat_op, cat_of_op_quiver );
    AddObjectFunction( dual, 
        function( r )
        return QuiverRepresentation( A_op, DimensionVector( Opposite(r) ), Arrows( Q_op ), List( MatricesOfRepresentation( Opposite(r) ), TransposedMat ) );
        end );
    AddMorphismFunction( dual,
        function( new_source, phi, new_range )
        return QuiverRepresentationHomomorphism( new_source, new_range, List( MatricesOfRepresentationHomomorphism( Opposite( phi ) ), TransposedMat ) );
        end );
    return dual;
end;

compute_lifts_in_complexes := 
    function( f, g )
    local m, n, A, f_, g_, lift; 
    m := Minimum( ActiveLowerBound( Source(f) ), ActiveLowerBound( Source(g) ) ) + 1;
    n := Minimum( ActiveUpperBound( Source(f) ), ActiveUpperBound( Source(g) ) ) - 1;
    
    if IsChainMorphism( f ) then
        A := product_of_algebras( AlgebraOfRepresentation( Source(f[ m ]) ), n, m );
    else
        A := product_of_algebras( AlgebraOfRepresentation( Source(f[ m ]) ), m, n );
    fi;
    
    f_ := convert_chain_or_cochain_mor_to_representation_mor( f, A );
    g_ := convert_chain_or_cochain_mor_to_representation_mor( g, A );
    
    lift := compute_lift_in_quiver_rep( f_, g_ );
    
    if lift = fail then 
        return fail;
    else 
        return convert_rep_mor_to_complex_mor( Source(f), Source( g ), lift, A );
    fi;
end;

compute_colifts_in_complexes := 
    function( f, g )
    local m, n, A, f_, g_, colift; 
    m := Minimum( ActiveLowerBound( Source(f) ), ActiveLowerBound( Source(g) ) ) + 1;
    n := Minimum( ActiveUpperBound( Source(f) ), ActiveUpperBound( Source(g) ) ) - 1;
    
    if IsChainMorphism( f ) then
        A := product_of_algebras( AlgebraOfRepresentation( Source(f[ m ]) ), n, m );
    else
        A := product_of_algebras( AlgebraOfRepresentation( Source(f[ m ]) ), m, n );
    fi;
    
    f_ := convert_chain_or_cochain_mor_to_representation_mor( f, A );
    g_ := convert_chain_or_cochain_mor_to_representation_mor( g, A );
    
    colift := compute_colift_in_quiver_rep( f_, g_ );
    
    if colift = fail then 
        return fail;
    else 
        return convert_rep_mor_to_complex_mor( Range(f), Range( g ), colift, A );
    fi;
end;

########################################################

k := Rationals;
Q := RightQuiver("Q(4)[a:1->2,b:1->3,c:2->4,d:3->4]" );
kQ := PathAlgebra( k, Q );
AQ := QuotientOfPathAlgebra( kQ, [ kQ.ac-kQ.bd ] );

#           a
#       1 ---> 2
#     b |      | c
#       v      V
#       3 ---> 4
#          d

cat := CategoryOfQuiverRepresentations( AQ: FinalizeCategory := false );

AddEpimorphismFromSomeProjectiveObject( cat, ProjectiveCover );
SetIsAbelianCategoryWithEnoughProjectives( cat, true );
AddIsProjective( cat, function( R ) 
                        return IsIsomorphism( ProjectiveCover( R ) ) ;
                      end );
AddLift( cat, compute_lift_in_quiver_rep );
AddColift( cat, compute_colift_in_quiver_rep );
Finalize( cat );

chains := ChainComplexCategory( cat: FinalizeCategory := false );
AddLift( chains, compute_lifts_in_complexes );
AddColift( chains, compute_colifts_in_complexes );
Finalize( chains );