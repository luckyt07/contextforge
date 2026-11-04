"""add column for conversation ID

Revision ID: 5b61ef9cc42a
Revises: 80a22ad8fe19
Create Date: 2026-10-23 20:33:17.811964

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '5b61ef9cc42a'
down_revision: Union[str, Sequence[str], None] = '80a22ad8fe19'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.add_column('project_conversations', sa.Column('conversation_id', sa.String(), nullable=True))


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column('project_conversations', 'conversation_id')
