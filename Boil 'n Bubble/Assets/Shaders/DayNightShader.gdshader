shader_type sky;
render_mode use_half_res_pass;

uniform vec3 topSkyDay : source_color;
uniform vec3 horizonSkyDay : source_color;

uniform vec3 topSkyNight : source_color;
uniform vec3 horizonSkyNight : source_color;

uniform vec3 topSunRiseSet : source_color;
uniform vec3 horizonSunRiseSet : source_color;

uniform vec3 sunColor : source_color;
uniform float sunSize = 0.2;

uniform vec3 moonColor : source_color;
uniform float moonSize = 0.1;
uniform float moonOffset = 0.05;

void sky() {
	//Create Sun and define Sun position
	float sunDirection = distance(EYEDIR.xyz, LIGHT0_DIRECTION);
	float sunPosition = 1.0 - clamp(sunDirection / sunSize, 0.0, 1.0);
	float sunDisk = step(sunSize, sunPosition);
	vec4 sun = vec4(sunColor, sunDisk);
	
	//Create Moon and define Moon position
	float moonDirection = distance(EYEDIR.xyz, -LIGHT0_DIRECTION);
	float moonPosition = 1.0 - clamp(moonDirection / moonSize, 0.0, 1.0);
	float moonDisk = step(moonSize, moonPosition);
	float moonCrescentDirection = distance(vec3(EYEDIR.x + moonOffset, EYEDIR.yz), -LIGHT0_DIRECTION);
	float moonCrescentPosition = 1.0 - clamp(moonCrescentDirection / moonSize, 0.0, 1.0);
	float moonCrescentDisk = step(moonSize, moonCrescentPosition);
	vec4 moon = vec4(moonColor, clamp(moonDisk - moonCrescentDisk, 0.0, 1.0));
	
	//Create Sky color gradients
	float colorGradient = clamp(EYEDIR.y, 0.0, 1.0);
	vec3 skyColorDay = mix(horizonSkyDay, topSkyDay, colorGradient);
	vec3 skyColorNight = mix(horizonSkyNight, topSkyNight, colorGradient);
	vec3 skyColorSunRiseSet = mix(horizonSunRiseSet, topSunRiseSet, colorGradient);
	
	vec3 skyColor = vec3(0.0, 0.0, 0.0);
	
	//Apply sky gradient based on time of day
	if (LIGHT0_DIRECTION.y > 0.0) {
		skyColor = mix(skyColorSunRiseSet, skyColorDay, LIGHT0_DIRECTION.y);
		/*if (LIGHT0_DIRECTION.y > 0.1) {
			skyColor = skyColorDay;
		} else {
			skyColor = mix(skyColorDay, skyColorSunRiseSet, LIGHT0_DIRECTION.y);
		}*/
	} else {
		skyColor = mix(skyColorSunRiseSet, skyColorNight, abs(LIGHT0_DIRECTION.y));
		/*if (LIGHT0_DIRECTION.y > -0.3) {
			skyColor = mix(skyColorSunRiseSet, skyColorNight, abs(LIGHT0_DIRECTION.y));
		} else {
			skyColor = skyColorNight;
		}*/
	}
	skyColor = mix(skyColor, sun.rgb, sun.a);
	skyColor = mix(skyColor, moon.rgb, moon.a);
	COLOR = skyColor;
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
}
