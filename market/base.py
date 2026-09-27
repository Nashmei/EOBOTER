from abc import ABC,abstractmethod
class MarketDataGateway(ABC):
    @abstractmethod
    def closes(self,symbol:str,interval:str="1m",limit:int=100)->list[float]: raise NotImplementedError
