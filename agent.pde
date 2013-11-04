float speed = 25;
float minWeight = 0.25;  // this is const-ish for now

// you may not notice it, but there are five 'lines' drawn at a time right now
// (but they're mostly overlapping until you go and customize how they move)
static int MAX_AGENTS = 5;
int agentCount = 0;
Agent[] swarm = new Agent[MAX_AGENTS];

void addAgent(float x, float y) {
  if (agentCount < MAX_AGENTS) {
    swarm[agentCount] = new Agent(x, y);
    agentCount++;
  }
}

void clearAgents() {
  swarm = new Agent[MAX_AGENTS];
  agentCount = 0;
}

void updateAll() {
  for (int i=0; i < agentCount; i++) {
    swarm[i].aimTowardsPoint(new PVector(mouseX, mouseY));
    swarm[i].update();
  }
}

void drawAll() {
  for (int i=0; i < agentCount; i++) {
    swarm[i].draw();
  }
}

void killAgent(int targetIndex) {
  for (int i=targetIndex; i < agentCount-1; i++) {
    swarm[i] = swarm[i+1];
  }
  agentCount--;
}

// This class is what you want to change up if you want your drawing to actually be
// unique. An Agent is a thing with a position and velocity that leaves a line wherever
// it moves. If you change how it moves, you change how it draws.
class Agent {
  PVector pos;
  PVector vel;
  PVector lastpos;
  
  float sat;
  float b;
  float weight;

  Agent(float x, float y) {
    pos = new PVector(x, y);
    lastpos = new PVector(x, y);
    sat = random(256, 256);
    b = bright;
    weight = pensize;
  }
  
  void aimTowardsPoint(PVector target) {
    vel = PVector.sub(target, pos); // vector from agent to target
    if (vel.mag() > speed) {
      vel.setMag(speed);
    }
  }

  void update() {
    lastpos.x = pos.x;
    lastpos.y = pos.y;
    pos.add(vel);
  }
  
  void draw() {
    strokeWeight(weight);
    stroke(hue, sat, b);  // note: hue is global, others are local
    line(lastpos.x, lastpos.y, pos.x, pos.y);

    if (weight < minWeight) {
      weight = minWeight;
    }
  }
  
  
}
