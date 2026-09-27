from gateways.demo import DemoGateway


def test_demo_gateway_health() -> None:
    assert DemoGateway().health() is True
