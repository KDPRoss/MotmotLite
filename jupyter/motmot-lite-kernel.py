# Hacky MotmotLite Jupyter Kernel.

# You may need to `pip install metakernel` to make this
# work.

from ipykernel.kernelbase import Kernel
import subprocess

# Cargo-cult OOP nonsense. What a ridiculous programming
# paradigm ... and badly implemented in Python.
class MotmotLiteKernel(Kernel):
    implementation = 'MotmotLite'
    implementation_version = '1.0'
    language = 'MotmotLite'
    language_version = 'MotmotLite'
    language_info = {
        'name': 'MotmotLite',
        'mimetype': 'text/plain',
        'file_extension': '.mot',
    }
    banner = 'MotmotLite'

    proc = subprocess.Popen(['MotmotLite', '--kernel'], stdin = subprocess.PIPE, stdout = subprocess.PIPE)

    def one(self, s):
        self.proc.stdin.write(bytes(s + '\n', 'utf-8'))
        self.proc.stdin.flush()

        res = []
        sOut = ''
        while '<<<KERNEL-FINISHED>>>' not in sOut:
            if '' != sOut:
                res.append(sOut)
            sOut = self.proc.stdout.readline().decode('utf-8')
            sOut = sOut.rstrip(' \n')

        return '\n'.join(res)

    def do_execute(self, code, silent, store_history = True, user_expressions = None, allow_stdin = False):
        try:
            out = self.one(' '.join(code.split('\n'))).rstrip(' \n')
        except Exception as e:
            out = '(Kernel failure: `' + str(e) + '`)'
        stream_content = {'name': 'stdout', 'text': out}
        self.send_response(self.iopub_socket, 'stream', stream_content)

        return {
            'status': 'ok',
            # The base class increments the execution count
            'execution_count': self.execution_count,
            'payload': [],
            'user_expressions': {},
        }

if __name__ == '__main__':
    from ipykernel.kernelapp import IPKernelApp
    IPKernelApp.launch_instance(kernel_class = MotmotLiteKernel)
