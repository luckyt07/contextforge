"""added support for firstname and lastname

Revision ID: 84f6e29455b1
Revises: ee90aabdddd6
Create Date: 2026-10-23 17:48:43.232538

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '84f6e29455b1'
down_revision: Union[str, Sequence[str], None] = 'ee90aabdddd6'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.add_column('users', sa.Column('firstname', sa.String(), nullable=True))
    op.add_column('users', sa.Column('lastname', sa.String(), nullable=True))


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column('users', 'lastname')
    op.drop_column('users', 'firstname')
