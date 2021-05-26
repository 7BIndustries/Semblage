# Copyright (c) 2011-2021, Manfred Moitzi
# License: MIT License


class Options:
    def __init__(self):
        self.filter_invalid_xdata_group_codes = False
        self.default_text_style = 'OpenSans'
        self.default_dimension_text_style = 'OpenSansCondensed-Light'

        # Active the matplotlib font support to calculate font metrics:
        # This requires a working matplotlib installation else an ImportError
        # exception will be raised. This feature also depends on the
        # ezdxf.addons.drawing add-on
        self.use_matplotlib_font_support = False

        # Set path to an external font cache directory: e.g. "~/ezdxf", see
        # docs for ezdxf.options for an example how to create your own
        # external font cache:
        self.font_cache_directory = False

        # debugging
        self.log_unprocessed_tags = True

        # Proxy graphic handling:
        # Set 'load_proxy_graphics' to True for loading proxy graphics
        self.load_proxy_graphics = False
        # Set 'store_proxy_graphics' to True for exporting proxy graphics
        self.store_proxy_graphics = False

        # Enable this option to always create same meta data for testing
        # scenarios, e.g. to use a diff like tool to compare DXF documents.
        self.write_fixed_meta_data_for_testing = False

    def preserve_proxy_graphics(self):
        """ Enable proxy graphic load/store support. """
        self.load_proxy_graphics = True
        self.store_proxy_graphics = True


# Global Options
options = Options()
