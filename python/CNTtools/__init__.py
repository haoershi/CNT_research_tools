import pkgutil
import importlib
import CNTtools  # assuming X is the name of the package

# iterate over all module names in the X package
for loader, name, is_pkg in pkgutil.walk_packages(CNTtools.__path__):
    # import the module and add its functions to the package namespace
    module = importlib.import_module(f"{CNTtools.__name__}.{name}")
    for key, value in module.__dict__.items():
        if callable(value):
            setattr(CNTtools, key, value)
