var debug = false
decodeURIComponent(document.cookie).split(";").forEach(function(e,i,a) { var kv=e.split("="); console.log(kv); if (kv[0]=="debug" && kv[1]=="true") {debug = true} })
if (debug) {
	BABYLON.DebugLayer.InspectorURL = window.location.protocol + "//" + window.location.host + "/static/js/babylon.inspector.bundle.js";
}

var token;
decodeURIComponent(document.cookie).split(";").forEach(function(e,i,a) { var kv=e.split("="); if (kv[0]=="token") {token=kv[1]} })
if (!token) {
	alert("Missing token!")
}

function send_msg(action, data) {
	console.log('[WS] Client: ' + data.action, data)
	var _data = {
		token: token,
		action: action,
	}
	data.keys().forEach(function(k) {
		_data[k] = data[k]
	})
	con.send(JSON.stringify(_data))
}

var con = new WebSocket(((window.location.protocol === "https:") ? "wss://" : "ws://") + window.location.host + "/ws");





var canvas = document.getElementById("render_canvas"); // Get the canvas element 
var engine = new BABYLON.Engine(canvas, true); // Generate the BABYLON 3D engine
/******* Add the create scene function ******/
var createScene = function () {
	var scene = new BABYLON.Scene(engine);
	scene.collisionsEnabled = true;
	
	scene.ambientColor = new BABYLON.Color3(0, 0, 0);
	scene.fogColor = new BABYLON.Color3(0, 0, 0);
	scene.clearColor = new BABYLON.Color3(0, 0, 0);
	
	//var camera = new BABYLON.ArcRotateCamera("Camera", Math.PI / 2, Math.PI / 2, 2, BABYLON.Vector3.Zero(), scene);
	
	var cam = new BABYLON.FreeCamera("camera", new BABYLON.Vector3(1,2,1), scene);
	
	cam.ellipsoid = new BABYLON.Vector3(0.5, 1, 0.5);
	cam.speed = 0.5;
	cam.inertia = 0.9;
	cam.fov = 0.9
	
	cam.attachControl(canvas, true);
	cam.checkCollisions = true;
    cam.applyGravity = true;
	
	var light1 = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 100, 0), scene);
	light1.intensity = 0.1;
	//var light2 = new BABYLON.PointLight("light2", new BABYLON.Vector3(0, 1, -1), scene);
	
	//var light = new BABYLON.PointLight("pointLight", new BABYLON.Vector3(1, 1, 1), scene);
	//var light = new BABYLON.SpotLight("spotLight", new BABYLON.Vector3(0, 10, 0), new BABYLON.Vector3(0, -1, 0), Math.PI / 3, 2, scene);

	var mat_box = new BABYLON.StandardMaterial("mat_box", scene);
	mat_box.diffuseTexture = new BABYLON.Texture("/static/assets/texture2.png", scene, false, true, BABYLON.Texture.NEAREST_SAMPLINGMODE);

	var mat_wall = new BABYLON.StandardMaterial("mat_box", scene);
	mat_wall.diffuseTexture = new BABYLON.Texture("/static/assets/texture2.png", scene, false, true, BABYLON.Texture.NEAREST_SAMPLINGMODE);
	mat_wall.diffuseTexture.vScale = 10

	for (z=0; z<16; z++) { 
		for (x=0; x<16; x++) {
			var box
			if ((x%15==0) || (z%15==0)) {
				// border blocks
				box = BABYLON.MeshBuilder.CreateBox("box_"+x+"_"+z, {height: 10, width: 1, depth: 1}, scene);
				box.position.y = 5;
				box.material = mat_wall;
			} else {
				// center blocks
				box = BABYLON.MeshBuilder.CreateBox("box_"+x+"_"+z, {height: 1, width: 1, depth: 1}, scene);
				box.material = mat_box;
			}
			box.checkCollisions = true;
			box.position.x = x;
			box.position.z = z;
		}
	}
	
	return scene;
};

var scene = createScene();
if (debug) {
	scene.debugLayer.show();	
}


var chunks = {}



con.onopen = function () {
	console.log('WebSocket Open');
	send_msg("get_area", {});

};

con.onerror = function (error) {
	console.log('WebSocket Error ' + error);
};

con.onmessage = function (e) {
	var obj = JSON.parse(e.data);
	if (obj.type == "error") {
		console.log('[WS] Server (error): ' + obj.msg);
	} else {
		console.log('[WS] Server: ' + obj);
	}
};







engine.runRenderLoop(function () {
	scene.render();
});

window.addEventListener("resize", function () {
	engine.resize();
});
