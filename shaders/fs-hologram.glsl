uniform float stepDepth;
uniform float oscillationSize;
uniform vec3 lightPos;
uniform sampler2D t_text;
uniform sampler2D t_noise;

uniform float time;

uniform float hovered;

varying mat3 vINormMat;

varying vec3 vTang;
varying vec3 vNorm;
varying vec3 vMNorm;
varying vec3 vBino;

varying vec2 vUv;

varying vec3 vEye;
varying vec3 vMPos;
varying vec3 vPos;

$hsv
$simplex

vec3 desaturate(vec3 color, float amount)
{
    vec3 gray = vec3(dot(vec3(0.2126,0.7152,0.0722), color));
    return vec3(mix(color, gray, amount));
}

#define STEPS 8
vec4 volumeColor( vec3 ro , vec3 rd , mat3 iBasis ){

  vec3 col = vec3(0.,0.,1.);
  float lum = 0.;
  for( int i = 0; i < STEPS; i++ ){

    vec3 p = ro - rd * float( i ) * stepDepth;
   
    p = iBasis * p;
    //float lu = snoise( (p.yz * 6. + vec2( time * .2  , 0. )) );
    //lu += snoise( (p.yz * 30. + vec2( time * .1  , 0. )) );

    vec4 t = texture2D( t_text , vec2( -p.y * 2.  + .5 , p.z * 2. + .5 )  );
    vec4 c = texture2D( t_noise , vec2( -p.y * 2.  + .5 , p.z * 2. + .5 ) + vec2( float(i) * 21.3 + time , float(i)  * 37.3 - time) );

    if( t.a - length(c) * .2  > .4 ){ col = vec3(1.,0.,0.) + vec3(1.) * (mod(float(i)+hovered,2.))  ; break; }
  } 



  vec4 fC = vec4( col , 0. );//vec4( col , 1. ) / float( STEPS );

 // fC.xyz = mix( fC.xyz , desaturate( fC.xyz , -2.6 ) , hovered );
   return vec4(  fC.xyz , 1.);


}

void main(){


  vec3 col = vTang * .5 + .5;
  float alpha = 1.;

  vec3 lightDir = normalize( lightPos - vMPos );
  vec3 reflDir = reflect( lightDir , vNorm );
  
  float lightMatch = max( 0. , dot(-lightDir ,  vNorm ) );
  float reflMatch = max( 0. , dot(reflDir ,  vEye) );

  reflMatch = pow( reflMatch , 20. );

  vec4 volCol = volumeColor( vPos , normalize(vEye) , vINormMat );

 /* vec3 lambCol = lightMatch * volCol.xyz;
  vec3 reflCol = reflMatch * (vec3(1.) - volCol.xyz);

  vec4 aCol = texture2D( t_text, vUv );*/

  col = volCol.xyz;

  vec4 c = texture2D( t_noise , vUv );
  //col *= (length(c.xyz)* .6+.3 + hovered);
  if( .5 - abs((vUv.x-.5)) < .01 + c.z * .1  ){ discard; };
  if( .5 - abs((vUv.y-.5)) < .01 + c.z * .1  ){ discard; };

  gl_FragColor =  vec4( col  , 1.  );


  //gl_FragColor = vec4( normalize( vEye ) * .5 + .5 , 1. );
  //gl_FragColor = vec4( vTang , 1. ); 

}
