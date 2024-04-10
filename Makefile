all: slurm.html slurm_onepage.html conda.html conda_onepage.html

slurm_onepage.html: slurm.md
	pandoc -s -o slurm_onepage.html slurm.md

slurm.html: slurm.md
	pandoc -s --webtex -t slidy -o slurm.html slurm.md

conda_onepage.html: conda.md
	pandoc -s -o conda_onepage.html conda.md

conda.html: conda.md
	pandoc -s --webtex -t slidy -o conda.html conda.md

clean:
	rm -rf slurm.html slurm_onepage.html conda.html conda_onepage.html
