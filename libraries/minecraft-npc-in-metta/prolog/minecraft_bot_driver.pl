/** <module> Minecraft Bot Driver
 *  Handles command queuing, event handling, movement, and voxel data management.
 */

:- use_module(library(jpl)).

:- dynamic command_queue/1.
:- dynamic bot_controller/1.
:- dynamic voxel_data/4.


bot_contoller_class('io.trueagi.mettalog.minecraft.BotController').

get_bot_controller(Bot):- bot_controller(Bot),!.
get_bot_controller(Bot):- bot_contoller_class(Class),jpl_new(Class,[],Bot),!.
%get_bot_controller(Bot):- trace, bot_contoller_class(Bot),!.

status:- bot_call(status,[],_Return).

bot_call(Method,Args,Return):-
    get_bot_controller(Bot),    % Retrieve Java object reference
    jpl_call(Bot, Method, Args, Return).


%% enqueue_command(+Command) is det.
%  Adds a command to the command queue for Java to execute.
%  @param Command The command to be added to the queue.
enqueue_command(Command) :-
    assertz(command_queue(Command)),
    format("Queued command: ~w~n", [Command]).

%% dequeue_command(-Command) is semidet.
%  Retrieves and removes the next command from the queue.
%  @param Command The next command from the queue.
dequeue_command(Command) :-
    retract(command_queue(Command)),!.

%% login(+Username, +Password, +Server, +Port) is det.
% Call login method on the registered bot_controller object
login(Username, Password, Server, Port) :-
    bot_call('login', [Username, Password, Server, Port], _).


login0 :-
    get_bot_controller(Bot),    % Retrieve Java object reference
    jpl_call(Bot, 'login0', [], _).


%% move(+X, +Y, +Z) is det.
%  Queues a movement command for execution.
move(X, Y, Z) :- enqueue_command(move(X, Y, Z)).

%% chat(+Message) is det.
%  Queues a chat message.
chat(Message) :- enqueue_command(chat(Message)).

%% on_bot_connected is det.
%  Handles bot connection.
on_bot_connected :-
    format("Bot successfully connected!~n"),
    chat("Hello world, I am online!").

%% on_bot_disconnected(+Reason) is det.
%  Handles bot disconnection.
%  @param Reason The reason for disconnection.
on_bot_disconnected(Reason) :-
    format("Bot disconnected: ~w~n", [Reason]).

%% on_bot_killed(+Reason) is det.
%  Handles bot death and triggers respawn.
%  @param Reason The reason the bot was killed.
on_bot_killed(Reason) :-
    format("Bot was killed: ~w~n", [Reason]),
    format("Respawning bot...~n"),
    respawn_bot.

%% respawn_bot is det.
%  Respawns the bot by issuing a login command.
respawn_bot :-
    login('MeTTaPrologBot', '', 'localhost', 25565),
    format("Respawn command issued~n").

%% on_chat_message(+Message) is det.
%  Handles chat messages received by the bot.
%  @param Message The chat message.
on_chat_message(Message) :-
    format("Chat received: ~w~n", [Message]),
    (Message = "hello bot" -> chat("Hello, player!");
     Message = "who are you" -> chat("I am a Prolog-powered bot!");
     Message = "respawn" -> respawn_bot;
     Message = "scan area" -> request_voxel_data;
     Message = "show voxels" -> print_voxel_data;
     format("Ignoring chat: ~w~n", [Message])).

%% request_voxel_data is det.
%  Requests voxel data from the Java bot.
request_voxel_data :-
    enqueue_command(request_voxel_data),
    format("Voxel data request sent to Java.~n").

%% on_voxel_data(+X, +Y, +Z, +BlockID) is det.
%  Stores voxel data received from Java.
%  @param X The X coordinate.
%  @param Y The Y coordinate.
%  @param Z The Z coordinate.
%  @param BlockID The block ID at the position.
on_voxel_data(X, Y, Z, BlockID) :-
    retractall(voxel_data(X, Y, Z, _)),  % Remove old data if exists
    assert(voxel_data(X, Y, Z, BlockID)), % Store new data
    format("Stored voxel data: (~w, ~w, ~w) -> Block ~w~n", [X, Y, Z, BlockID]).

%% print_voxel_data is det.
%  Prints all stored voxel data.
print_voxel_data :-
    format("Voxel Data Stored in Prolog:~n"),
    forall(voxel_data(X, Y, Z, BlockID),
        format("Voxel: (~w, ~w, ~w) -> Block ~w~n", [X, Y, Z, BlockID])).


:- writeln(loaded(minecraft_bot_driver)).
