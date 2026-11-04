"""add column in project table: summary and is_active

Revision ID: 2a59132744dc
Revises: 2ff30746ecfc
Create Date: 2026-10-22 17:02:26.088829

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '2a59132744dc'
down_revision: Union[str, Sequence[str], None] = '2ff30746ecfc'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.add_column('projects', sa.Column('summary', sa.Text(), nullable=True))
    op.add_column('projects', sa.Column('is_active', sa.Boolean(), nullable=False, server_default=sa.false()))


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column('projects', 'is_active')
    op.drop_column('projects', 'summary')
