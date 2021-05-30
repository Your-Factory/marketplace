import * as THREE
    from 'https://cdn.skypack.dev/pin/three@v0.129.0-chk6X8RSBl37CcZQlxof/mode=imports,min/optimized/three.js';
import {OBJLoader}
    from 'https://cdn.skypack.dev/pin/three@v0.129.0-chk6X8RSBl37CcZQlxof/mode=imports,min/unoptimized/examples/jsm/loaders/OBJLoader.js';
import {OrbitControls}
    from 'https://cdn.skypack.dev/pin/three@v0.129.0-chk6X8RSBl37CcZQlxof/mode=imports,min/unoptimized/examples/jsm/controls/OrbitControls.js';

let camera, scene, renderer, controls, object;

function changeToScene(model_json) {
    let main_image = document.getElementById('main_image');
    while (main_image.firstChild) {
        main_image.removeChild(main_image.lastChild);
    }

    let model = JSON.parse(model_json);
    let container = document.createElement('div');
    let parent = container;

    container.setAttribute('class', 'main_product_image');
    main_image.appendChild(container);

    init(container, model);
    animate();
}

function init(container, model_bytes) {
    camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 1, 2000);
    camera.position.z = 20;

    scene = new THREE.Scene();

    const ambientLight = new THREE.AmbientLight(0x1c1c1c, 0.4);
    scene.add(ambientLight);

    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
    camera.add(directionalLight);
    scene.add(camera);

    function loadModel() {
        object.position.y = 0;
        scene.add(object);
    }

    const manager = new THREE.LoadingManager(loadModel);

    let loader = new OBJLoader(manager);
    let model = loader.parse(model_bytes);
    scene.add(model);

    renderer = new THREE.WebGLRenderer();
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(window.innerWidth, window.innerHeight);
    container.appendChild(renderer.domElement);

    controls = new OrbitControls(camera, renderer.domElement);
    controls.panSpeed = 0.6;
    controls.zoomSpeed = 1.0;
    controls.rotateSpeed = 1.0;

    controls.listenToKeyEvents(window);
    controls.addEventListener('change', render);
    controls.screenSpacePanning = true;

    controls.minDistance = 10;
    controls.maxDistance = 500;
    controls.update();

    window.addEventListener('resize', onWindowResize);
}

function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}

function animate() {
    requestAnimationFrame(animate);
    controls.update();
    render();
}

function render() {
    renderer.render(scene, camera);
}

window.changeToScene = changeToScene;
