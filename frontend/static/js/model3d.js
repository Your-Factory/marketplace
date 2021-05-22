let scene, camera, renderer;

scene = new THREE.Scene();
/*не цепляет*/
scene.background = new THREE.Color(0xdddddd);

camera = new THREE.PerspectiveCamera(40, window.innerWidth / window.innerHeight, 1, 5000);
camera.rotation.y = 45 / 180 * Math.PI;
camera.position.x = 800;
camera.position.y = 100;
camera.position.z = 1000;

renderer = new THREE.WebGLRenderer({antialias: true});
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

window.addEventListener('resize', function () {
    renderer.setSize(window.innerWidth / window.innerHeight);
    camera.aspect = window.innerWidth / window.innerHeight;
})

let loader = new THREE.GLTFLoader();

loader.load('../static/models/scene.gltf', function (gltf) {
    /* scene.add(gltf.scene);*/
    model = gltf.scene.children[0];
    model.scale.set(0.5, 0.5, 0.5);
    scene.add(gltf.scene);
    animate();
})

function animate() {
    renderer.render(scene, camera);
    requestAnimationFrame(animate);
}

animate();

/*https://www.youtube.com/watch?v=JUwnSK163zs*/