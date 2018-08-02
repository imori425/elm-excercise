module App exposing (..)

import Http
import Html exposing (..)
import Json.Decode exposing (string, Decoder, list)
import Json.Decode.Pipeline exposing (required, decode)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)


type alias Task =
    String


type alias TodoId =
    Int


type alias SearchWord =
    String


type Status
    = Complete
    | Active


type alias Todo =
    { todoId : TodoId
    , task : Task
    , status : Status
    }


type alias Model =
    { inputTask : Task
    , todos : List Todo
    , todoIdSequence : Int
    , searchWord : String
    }


type Msg
    = UpdateTodo Task
    | RegisterTodo
    | RemoveTodo TodoId
    | ChangeStatus TodoId Status
    | InputSearchWord SearchWord


initialModel : Model
initialModel =
    { inputTask = "", todos = [], todoIdSequence = 0, searchWord = "" }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ div [] [ span [] [ text "検索" ], input [ type_ "text", value model.searchWord, onInput InputSearchWord ] [] ]
        , input [ type_ "text", value model.inputTask, onInput UpdateTodo ] []
        , button [ onClick RegisterTodo ] [ text "追加" ]
        , ul []
            (List.map todoView <| (List.filter (\todo -> String.contains model.searchWord todo.task) model.todos))
        ]


todoView : Todo -> Html Msg
todoView todo =
    case todo.status of
        Complete ->
            li []
                [ span [ style [ ( "text-decoration", "line-through" ) ] ] [ text todo.task ]
                , button [ onClick (RemoveTodo todo.todoId) ] [ text "削除" ]
                , input [ type_ "checkbox", checked True, onClick (ChangeStatus todo.todoId Active) ] []
                ]

        Active ->
            li []
                [ span [] [ text todo.task ]
                , button [ onClick (RemoveTodo todo.todoId) ] [ text "削除" ]
                , input [ type_ "checkbox", checked False, onClick (ChangeStatus todo.todoId Complete) ] []
                ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateTodo task ->
            ( { model | inputTask = task }, Cmd.none )

        RegisterTodo ->
            ( { model
                | todos =
                    { todoId = model.todoIdSequence
                    , task = model.inputTask
                    , status = Active
                    }
                        :: model.todos
                , inputTask = ""
                , todoIdSequence = model.todoIdSequence + 1
              }
            , Cmd.none
            )

        RemoveTodo removeTodoId ->
            ( { model | todos = (List.filter (\todo -> todo.todoId /= removeTodoId) model.todos) }, Cmd.none )

        ChangeStatus todoId status ->
            let
                changeStatus todo =
                    if todo.todoId == todoId then
                        { todo | status = status }
                    else
                        todo
            in
                ( { model | todos = (List.map changeStatus model.todos) }, Cmd.none )

        InputSearchWord searchWord ->
            ( { model | searchWord = searchWord }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }