#import "../../mew/index.typ": *
#import "@preview/bob-draw:0.1.1": *
#show: template

= Mental model for agents

#link("/")[home]

This is a collection of notes, strategies and mental models about agents in games.

= Let's define "game"

In game theory, a game is a model where multiple agents interact with each other to achieve a specific goal.
What is interesting is that agents affects each other's outcomes, so there's often a combination of probability, strategy and decision making.
It can be used to model a wide range of interactions, from economics to biology...

In game theory, the payoff function gives a score to each agent based on the current state.
This gives a common goal to all agents, as they all want to maximize their payoff.
I'll not consider any payoff function and we will leave game theory from now on to focus on agents and their interaction to the game world.

First let's define some concepts:

== World

Everything starts from a world. It's an infinite space where everything is possible!
But because games are often a model of reality, we need to restrict it.

We define a _state_ as a set of variables that describe the world at a given time:

$
  "State" = { x_1, x_2, ..., x_n }
$

Each variable can represent anything: position, velocity, energy, or even abstract concepts.

== Agents

We define an _agent_ as an individual entity that lives in the world.

#margin-note[
  #render(
    ```
                  Agent
                .---------.
    inputs ---> |  State  | ---> outputs
                '---------'
    ```,
  )
]

An agent has:
- A state (internal knowledge and memory)
- A set of inputs, or sensors (how it perceives the world)
- A set of outputs, or actions (how it affects the world)

#margin-note[
  #render(
    ```
    .---------------.
    |     World     |
    |   .-------.   |    .---------.
    |   | {r1}  |   |    |         |
    |   |   *---+---+--->|  Agent  |
    |   |       |   |    |         |
    |   '-------'   |    '---------'
    '---------------'
          Only this part
          is visible
    ```,
  )
]

There's a sense of autonomy in the agent, as it will decide what actions to take based only on its state and inputs.
In most cases, agents don't have a full view of the world, they can only sense a part of it with their inputs:

We can define a _strategy_ as a function that maps the state of an agent to an action:

$
  "Strategy": ("state", "inputs") -> "action"
$

Agents can implement different strategies depending on their goals.

== Rules

The rules of the game define how the world state is initialized and how it can evolve.
Rules restrict the space of possible world states and actions, and hence the possible strategies as well.

We can represent the relationship between rules, world state, and agents like this:

#render(
  ```
  .-----------.       Affects state
  |   world   |  if action follows rules
  |   state   |<------------------.
  |     . - - |                    \
  |     !     |    .-------.       |
  |     !  *--+--->| Agent |--> action
  |     !     |    '-------'
  '-----------'
          ^
          +- - Perceptible
            part of the world
  ```,
)

== Game

We can now define a game with world $G$ as a tuple

$
  G = (S, A, R)
$

where:
- $S$ is the state of the world
- $A$ is the set of agents
- $R$ is the set of rules

In this model, _agents are not directly part of the world state_.
This doesn't mean that they don't exist inside the world, but that they are not part of the state that is shared between all agents.

This make agents _autonomous entities_. They can be anything: players, algorithms, AI, ...

When you play a game, you are an agent, you are part of the game, but your decision process is not inside the game itself.

=== Example: A grid world

#margin-note[
  #render(
    ```
          0   1   .   n
        .---+---+---+---.
      0 |   |   |   |   |
        |---+---+---+---+
      1 |   | A |   | A |  A = Agent
        |---+---+---+---+
      . |   |   |   |   |
        |---+---+---+---+
      n |   |   |   |   |
        '---+---+---+---'
    ```,
  )
]

Let's consider a simple game where the world is a 2D grid and the agent can move in the four cardinal directions.

Each cell can be empty or contain an agent, so we can represent one cell with a binary variable $x_(i,j)$ \
The grid has $n * n$ cells, so we can represent the state of the world with $n^2$ variables.

$
  S = { x_(0,0), x_(0,1), ..., x_(n,n) }
$

Rules are simple: An agent can move up, down, left or right as long as the target cell is empty and inside the grid.\
In a more formal way, for an agent at position $(i,j)$, we can define the following rules:

#margin-note[
  #render(
    ```
        0   1   .   n
      .---+---+---+---.
    0 |   |   |   |   |
      |---+---+---+---+
    1 |   | A |   | A |  A = Agent
      |---+---+---+---+  * = Target
    . |   |   |   |   |
      |---+---+---+---+
    n |   |   | * |   |
      '---+---+---+---'
    ```,
  )
]

$
  r_1 = (x_(i,j) = 1) and (x_(i-1,j) = 0) and (i > 0), "// up"\
  r_2 = (x_(i,j) = 1) and (x_(i+1,j) = 0) and (i < n), "// down"\
  r_3 = (x_(i,j) = 1) and (x_(i,j-1) = 0) and (j > 0), "// left"\
  r_4 = (x_(i,j) = 1) and (x_(i,j+1) = 0) and (j < n) "// right"\
  R = { r_1, r_2, r_3, r_4 }
$

Now agents can move freely around with these specific rules.
Maybe they have a target as payoff: move to a specific case first! Who will win?

== World evolution

Until now, we only defined the initial state of the world and the rules that define how agents can impact the world.
In most case, the world is not static and can evolve over time by itself, without any agent intervention.
For this, we discretize the world time in steps, noted $t$ (named `tick` in video games).

At each step we can define a _transition function_ that maps the current state of the world to the next state.
We can consider for now that this function is pure, meaning that it doesn't depend on any external factor and is deterministic:

$
  "Transition": S_t -> S_(t+1)
$

This evolution happens independently of agent actions. However, we can extend the transition function to include agent actions:

$
  "Transition": (S_t, "actions") -> S_(t+1)
$

When agents submit actions, they are added to a queue and executed in order at the next step, if valid according to the rules.

= Core Challenges for Agents

This model provides a good theoretical framework, but agents face several challenges when operating in complex worlds:

== World State Interpretation

The visible part of the world must be transformed into meaningful, actionable data:

$
  "Perception": "WorldState" -> "AgentState"
$

An agent needs to filter, process, and structure raw input data into a format that enables efficient decision-making.
This is particularly challenging when the world state is complex or contains noise, requiring sophisticated sensors processing, pattern recognition, web-scraping, etc...

== Action Space Mapping

Agents must maintain a clear understanding of actions they can make:

$
  "ActionMapping": ("AgentState", "Action") -> "WorldState"'
$

This mapping isn't always straightforward, especially in environments where actions are not well defined, and have complex, delayed or unknown consequences.
Agents need to understand not just what actions are possible, but also their implications and effectiveness for the desired goal(s).

== Transition Function Understanding

This leads to maybe the most challenging aspect: the understanding and prediction of the world's evolution.

$
  "WorldModel": ("State"_t, "actions") -> "State"_(t+1)
$

Agents must develop internal models to:

- Keep track of the current (perceptible) world state
- Predict future states based on possible actions
- Understand how their actions interact with the world's natural evolution (see previous section)
- Take into account uncertainty and incomplete information

All of these challenges arise in complex environments where the transition function is opaque or highly nonlinear, making prediction and planning significantly more difficult.
This is something that us, human, are really good at doing: we've been improving this for more than 300,000 years with evolution.
But in most of the current artificial agents, we mostly developed specific algorithms in systems where everything is well defined.

Artificial intelligence brings us a way to plug these capabilities directly into our agents through learning and adaptation.
Instead of explicitly programming rules and predictions, we can create agents that develop their own internal models of the world, much like we do!
By combining evolutionary principles with AI, we can build agents that gradually improve their understanding of complex environments and learn to make decisions with incomplete information.

= Looking ahead

#margin-note[
  #render(
    ```
       Twitter                   Agent              Private Email
    .------------.         .--------------.        .------------.
    |            |         |   .------.   |        |             |
    |    🐦      |    A    |   |State |   |   B    |     📧      |
    |            |<--------+---|      |---+------->|             |
    '------------'         |   '------'   |        '-------------'
                           |     ^  |     |
                           |     |  V     |
                           |   .------.   |          Weather API
                           |   | Enc  |   |        .------------.
                           |   | Dec  |   |   C    |       ️     |
                           |   | Data |---+------->|     🌤       |
                           |   '------'   |        |             |
                           '--------------'        '-------------'

      A = Twitter API
      B = Email protocols
      C = Custom HTTP, REST API calls

      Agent maintains:
      - Authentication
      - Data format encoding, decoding
      - Privacy
    ```,
  )
]

We've defined the core components:

- World states and their evolution
- Agent architecture and autonomy
- Rules and constraints
- Key challenges in agent design

#margin-note[
  #render(
    ```
                           Emergent Behavior
                                  ^
                                  |
      .---.     .---.     .---.*  |      .---.
      | A |<--->| A |<--->| A |<--+----->| A |
      '---'     '-+-'     '-+-'   |      '---'
                  ^         ^     |        ^
                  |         |     |        |
      .---.     .-+-.     .-+-.*  |      .---.*
      | A |<--->| A |<--->| A |<--+----->| A |
      '---'     '-+-'     '-+-'          '---'
                  ^         ^
                  |         |
      .---.*    .-+-.     .-+-.*         .---.
      | A |<--->| A |<--->| A |<-------->| A |
      '---'     '---'     '---'          '---'

     A = Agent
    <-> = Local interaction, communication
     *  = Emergent pattern formation
    ```,
  )
]


Now that we have established a framework for understanding agents and their interaction with games worlds, we can start to explore more complex ideas:

+ _Autonomous Agent Implementation_: based on this mental framework, how to implement simple agents that can independently navigate and interact with their environment

+ _World Bridging_: how agents can serve as intermediaries between different worlds, to facilitate communication and interaction across environments (with state or stateless)

+ _Emergent Intelligence_: how agents can form their own worlds, creating biological systems where collective behavior emerges from all individual interactions, leading to swarm intelligence and adaptive systems

I really believe that agentic systems are a stepping stone toward a new paradigm in artificial intelligence.
We can create systems that are not just intelligent, but also adaptable, scalable, and capable of autonomous evolution.
The future of AI lies not in monolithic systems, but in fluid, interconnected networks of specialized agents, each contributing to a greater whole.

I hope that these thoughts will provides you a good foundation for thinking and building such systems!
