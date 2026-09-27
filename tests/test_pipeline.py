from core.pipeline import SignalPipeline
def test_pipeline_returns_ranked_signal():
    closes=[1+i*.001 for i in range(30)]
    row=SignalPipeline().analyze("TEST",closes,60)
    assert row is not None
    assert row.signal.asset=="TEST"
