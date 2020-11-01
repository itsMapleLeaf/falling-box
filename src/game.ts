import { Camera } from "./camera"
import { Clock } from "./clock"
import { FallingBlock } from "./falling-block"
import { canvas, context } from "./graphics"
import { HumanControllerTrait } from "./player/human-controller"
import { Player } from "./player/player"
import { RobotControllerTrait } from "./player/robot-controller"
import { vec } from "./vector"
import { World } from "./world"
import { WorldMap } from "./world-map"

const cameraStiffness = 8
const cameraOffset = vec(0, -150)

export class Game {
	blockSpawnClock = Clock.repeating(0.3)
	world = new World()
	map = new WorldMap(this.world)
	camera = new Camera()

	constructor() {
		this.world.add(new Player(this.map, new HumanControllerTrait()))
		this.world.add(new Player(this.map, new RobotControllerTrait()))
	}

	update(dt: number) {
		this.world.update(dt)

		const player = this.world.entities.find((e) => e.has(HumanControllerTrait))
		if (player) {
			this.camera.moveTowards(
				player.rect.center.plus(cameraOffset),
				dt * cameraStiffness,
			)
		}

		while (this.blockSpawnClock.advance(dt)) {
			this.world.add(new FallingBlock(this.map))
		}
	}

	draw() {
		context.clearRect(0, 0, canvas.width, canvas.height)

		this.camera.apply(() => {
			this.world.draw()
		})

		this.world.entities.forEach((e) => {
			e.getOptional(RobotControllerTrait)?.drawDebug()
		})
	}
}
