uniform float stepDepth;
uniform float oscillationSize;
uniform vec3 lightPos;
uniform sampler2D t_text;
uniform sampler2D t_matcap;
uniform sampler2D t_audio;

varying mat3 vINormMat;

varying vec3 vTang;
varying vec3 vNorm;
varying vec3 vBino;

varying vec2 vUv;

varying vec3 vEye;
varying vec3 vMPos;
varying vec3 vPos;

$hsv

#define STEPS 20
vec4 volumeColor( vec3 ro , vec3 rd , mat3 iBasis ){

  vec3 col = vec3( 0. );
  float lum = 0.;
  for( int i = 0; i < STEPS; i++ ){

    vec3 p = ro - rd * float( i ) * stepDepth;
   
    p = iBasis * p;
    float lu = abs(sin( p.y * oscillationSize ) +sin( p.z * oscillationSize ))/2.; 
    vec4 aCol = texture2D( t_audio , vec2( lu , 0.));

    lum += lu / 5.;
    col += aCol.xyz * hsv( p.x * 3. + lum / 20., 1. , 1. );

  } 

  return vec4( col , lum ) / float( STEPS );


}

void main(){


  vec4 tCol = texture2D( t_text, vUv );

  if( tCol.x < .2 ){ discard; }

  vec3 col = vTang * .5 + .5;
  float alpha = 1.;

  vec3 lightDir = normalize( lightPos - vMPos );
  vec3 reflDir = reflect( lightDir , vNorm );
  
  float lightMatch = max( 0. , dot(-lightDir ,  vNorm ) );
  float reflMatch = max( 0. , dot(reflDir ,  vEye) );

  reflMatch = pow( reflMatch , 20. );

  vec4 volCol = volumeColor( vPos , normalize(vEye) , vINormMat );

  vec3 lambCol = lightMatch * volCol.xyz;
  vec3 reflCol = reflMatch * (vec3(1.) - volCol.xyz);

  col = volCol.xyz;

  if( tCol.x > .2 && tCol.x < .4 ){ col = vec3( 1. ); }

  gl_FragColor = vec4( col , 1.  );


  //gl_FragColor = vec4( normalize( vEye ) * .5 + .5 , 1. );
  //gl_FragColor = vec4( vTang , 1. ); 

}
