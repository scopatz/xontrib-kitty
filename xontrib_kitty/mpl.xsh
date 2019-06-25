"""Matplotlib hooks for kitty"""
import sys
from io import BytesIO

from xonsh.tools import unthreadable
from xonsh.lazyasd import lazyobject
from xonsh import lazyimps


__all__ = ()


@lazyobject
def pylab_helpers():
    try:
        import matplotlib._pylab_helpers as m
    except ImportError:
        m = None
    return m


@lazyobject
def base64():
    import base64 as b64
    return b64


@lazyobject
def array():
    import array as arr
    return arr


def _get_buffer(fig, **kwargs):
    b = BytesIO()
    fig.savefig(b, **kwargs)
    b.seek(0)
    return b


def serialize_gr_command(cmd, payload=None):
    cmd = ','.join('{}={}'.format(k, v) for k, v in cmd.items())
    ans = []
    ans.append(b'\033_G')
    ans.append(cmd.encode('ascii'))
    if payload:
        ans.append(b';')
        ans.append(payload)
    ans.append(b'\033\\\n')
    return b''.join(ans)


def write_chunked(cmd, data):
    data = base64.standard_b64encode(data)
    while data:
        chunk, data = data[:4096], data[4096:]
        m = 1 if data else 0
        cmd['m'] = m
        sys.stdout.buffer.write(serialize_gr_command(cmd, chunk))
        sys.stdout.flush()
        cmd.clear()


def window_width():
    """returns the width of the window, in pixels."""
    buf = array.array('H', [0, 0, 0, 0])
    lazyimps.fcntl.ioctl(sys.stdout, lazyimps.termios.TIOCGWINSZ, buf)
    return buf[3]


@events.on_import_post_exec_module
def interactive_pyplot(module=None, **kwargs):
    """This puts pyplot in interactive mode once it is imported."""
    if module.__name__ != "matplotlib.pyplot" or not ${...}.get("XONSH_INTERACTIVE"):
        return
    # Since we might be in interactive mode, let's monkey-patch plt.show
    # to try to never block.
    module.ioff()  # start with interactive mode off.
    module._INSTALL_FIG_OBSERVER = False
    plt_show = module.show

    def xonsh_show(*args, **kwargs):
        """This is a monkey patched version of matplotlib.pyplot.show()
        for xonsh's interactive mode. First it tries non-blocking mode
        (block=False). If for some reason this fails, it will run show
        in normal blocking mode (block=True).
        """
        if module.isinteractive():
            # open a new window to interact with there
            kwargs.update(block=False)
            rtn = plt_show(*args, **kwargs)
            figmanager = pylab_helpers.Gcf.get_active()
            if figmanager is not None:
                # unblocked mode failed, try blocking.
                kwargs.update(block=True)
                rtn = plt_show(*args, **kwargs)
            return rtn
        else:
            # write directly to the screen
            fig = module.gcf()
            current_size = fig.get_size_inches() * fig.dpi
            w = window_width()
            fig.set_size_inches(w/fig.dpi,
                                current_size[1] * (w/ current_size[0] / fig.dpi))
            data = _get_buffer(fig, format="png", dpi=fig.dpi).read()
            write_chunked({'a': 'T', 'f': 100}, data)
            fig.set_size_inches(current_size / fig.dpi)

    module.show = xonsh_show

    # register figure drawer
    @events.on_postcommand
    def redraw_mpl_figure(**kwargs):
        """Redraws the current matplotlib figure after each command."""
        pylab_helpers.Gcf.draw_all()

