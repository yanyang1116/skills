// Standalone sketch code mirrored in neon-veil.html.

let params = {
    seed: 12345,
    particleCount: 7000,
    flowSpeed: 0.65,
    noiseScale: 0.006,
    trailLength: 14,
    colorPalette: ['#00f5ff', '#ff4dff', '#ffb86c']
};

let particles = [];
let flowField = [];
let cols, rows;
let scl = 12;
let flowZ = 0;
let center;
let faceA, faceB;

function setup() {
    createCanvas(1200, 1200);
    pixelDensity(1);
    initializeSystem();
}

function initializeSystem() {
    randomSeed(params.seed);
    noiseSeed(params.seed);

    flowZ = params.seed * 0.001;
    center = createVector(width / 2, height / 2);
    faceA = width * 0.28;
    faceB = height * 0.38;

    particles = [];
    for (let i = 0; i < params.particleCount; i++) {
        particles.push(new Particle());
    }

    cols = floor(width / scl);
    rows = floor(height / scl);
    generateFlowField();
    background(8, 8, 12);
}

function generateFlowField() {
    flowField = new Array(cols * rows);

    for (let y = 0; y < rows; y++) {
        for (let x = 0; x < cols; x++) {
            let px = x * scl - center.x;
            let py = y * scl - center.y;

            let n1 = noise(x * params.noiseScale, y * params.noiseScale, flowZ);
            let angle = n1 * TWO_PI * 2;

            let swirl = atan2(py, px) + HALF_PI;
            let ridge = noise(x * params.noiseScale * 0.6 + 10.7, y * params.noiseScale * 0.6 + 2.3, flowZ + 2.5);
            let mix = 0.25 + ridge * 0.35;
            angle = lerp(angle, swirl, mix);

            let v = p5.Vector.fromAngle(angle);
            v.setMag(1);
            flowField[x + y * cols] = v;
        }
    }
}

function draw() {
    let fadeAlpha = map(params.trailLength, 2, 30, 32, 6);
    background(8, 8, 12, fadeAlpha);

    flowZ += 0.0025;
    if (frameCount % 6 === 0) {
        generateFlowField();
    }

    blendMode(ADD);
    for (let i = 0; i < particles.length; i++) {
        particles[i].follow(flowField);
        particles[i].update();
        particles[i].show();
    }
    blendMode(BLEND);
}

class Particle {
    constructor() {
        this.reset(true);
    }

    reset(initial) {
        this.pos = randomPointInEllipse();
        if (!initial && random() < 0.2) {
            this.pos = randomPointOnHalo();
        }
        this.prev = this.pos.copy();
        this.vel = p5.Vector.random2D().mult(0.6);
        this.acc = createVector(0, 0);
        this.life = floor(random(200, 600));
        this.hueIndex = floor(random(params.colorPalette.length));
    }

    follow(field) {
        let x = floor(this.pos.x / scl);
        let y = floor(this.pos.y / scl);
        let index = x + y * cols;
        if (index >= 0 && index < field.length) {
            let force = field[index].copy();
            this.acc.add(force);
        }
    }

    update() {
        this.prev = this.pos.copy();

        let dx = this.pos.x - center.x;
        let dy = this.pos.y - center.y;
        let d = (dx * dx) / (faceA * faceA) + (dy * dy) / (faceB * faceB);

        if (d > 1) {
            let pull = createVector(-dx, -dy);
            pull.setMag((d - 1) * 0.8);
            this.acc.add(pull);
        } else {
            let lift = createVector(0, -0.08).mult(1.1 - d);
            let orbit = createVector(-dy, dx).setMag(0.05 * (1.0 - d));
            this.acc.add(lift);
            this.acc.add(orbit);
        }

        let veil = noise(this.pos.x * params.noiseScale * 0.8, this.pos.y * params.noiseScale * 0.8, flowZ + 4.7);
        let shimmer = map(veil, 0, 1, -0.3, 0.3);
        this.acc.add(createVector(shimmer, -shimmer * 0.2));

        this.acc.mult(params.flowSpeed);
        this.vel.add(this.acc);
        this.vel.limit(2.5);
        this.pos.add(this.vel);
        this.acc.mult(0);

        this.life -= 1;
        if (this.life <= 0 || this.outside()) {
            this.reset(false);
        }
    }

    outside() {
        return this.pos.x < -20 || this.pos.x > width + 20 || this.pos.y < -20 || this.pos.y > height + 20;
    }

    show() {
        let c = color(params.colorPalette[this.hueIndex]);
        let alpha = map(params.trailLength, 2, 30, 40, 140);
        let glow = noise(this.pos.x * 0.004, this.pos.y * 0.004, flowZ + 2.1);
        let weight = 0.5 + glow * 1.6;

        stroke(red(c), green(c), blue(c), alpha);
        strokeWeight(weight);
        line(this.prev.x, this.prev.y, this.pos.x, this.pos.y);
    }
}

function randomPointInEllipse() {
    let angle = random(TWO_PI);
    let r = sqrt(random());
    return createVector(
        center.x + r * faceA * cos(angle),
        center.y + r * faceB * sin(angle)
    );
}

function randomPointOnHalo() {
    let angle = random(TWO_PI);
    let r = faceA * 1.18 + random(-12, 12);
    return createVector(
        center.x + r * cos(angle),
        center.y + r * 1.05 * sin(angle)
    );
}
