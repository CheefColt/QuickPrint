from pydantic import BaseModel

class PrintConfig(BaseModel):
    copies: int = 1
    color: bool = False
    double_sided: bool = False

    class Config:
        from_attributes = True