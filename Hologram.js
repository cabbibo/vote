function Hologram( geo , uniforms , vs , fs ,transparent ){

  var t = transparent || false;
  var u = {
    iModelMat:{ type:"m4" , value: new THREE.Matrix4() }
  }

  for( var propt in uniforms ){
  
    u[propt] = uniforms[propt];

  }

  var mat = new THREE.ShaderMaterial({

    uniforms:       u,
    vertexShader:   vs,
    fragmentShader: fs,
    side: THREE.DoubleSide,
    transparent: t

  });
         

  var mesh = new THREE.Mesh( geo , mat );


  mesh.update = function(){
 
    this.updateMatrixWorld();
    this.material.uniforms.iModelMat.value.getInverse( this.matrixWorld );

  }.bind( mesh );

  return mesh;

}
