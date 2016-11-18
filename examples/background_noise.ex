defmodule Example.Scenario.BackgroundNoise do
  use Canary.Scenario

  def init(session) do
    session
    # incoming requests per interval
    |> assign(rate: 25)
    # spread request rate over this amount of time
    |> assign(interval: seconds(1))
    |> ok
  end

  def run(session) do
    session
    # |> loop(:spread_post_data, 10 |> minutes)
    ~> increase_noise
  end

  def spread_post_data(session = %{rate: r, interval: i}) do
    session
    |> cc_spread(:post_data, r, i)
    |> await_all(:post_data)
    ~> increase_noise
  end

  def post_data(session) do
    session
    |> post("/data", %{data: "hello, world!"})
  end

  def increase_noise(session) do
    session
    |> update_assign(rate: &(&1 * 1.025))
  end
end

alias Example.Scenario.BackgroundNoise

scenario = %Canary.Scenario{name: "test-scenario"}
session = %Canary.Session{id: "test-session", scenario: scenario}
{:ok, bg_session} = BackgroundNoise.init(session)
IO.inspect(BackgroundNoise.run(bg_session))